# Usage:
# Creation
#   p = PennExtranetAdapter.new( user, pw )
#
# Getting a page
#   source = p.get( url, params )
#   source = p.post( url, params )

# Directly accessing the authenticated mechanize object
#   o = p.authenticated_agent
#
class PennExtranetAdapter
  @authenticated_agent = nil
  
  def initialize(username, pw)
    @authenticated_agent = nil
    @username = username
    @pw = pw
  end
  
  # goes to the home extranet page and tries to detect if this is a valid
  # session or not. After a prolonged time period, a valid session may
  # become invalid
  def valid_agent?( agent = authenticated_agent )
    agent.get("https://extranet.uphs.upenn.edu")
    main_page_body = agent.page.body
    if main_page_body.include? "Please sign in to begin your secure session"
      puts "==CHECKING VALIDITY==...Invalid agent"
      false
    elsif main_page_body.include? "Welcome to the Secure Access SSL VPN"
      puts "==CHECKING VALIDITY==...Valid agent!"
      true
    else
      puts "==CHECKING VALIDITY==...Probably an invalid agent"
      false
    end
  end
  
  # returns the already-authenticated agent OR creates a new one
  def authenticated_agent 
    #returns an agent that is authenticated or a new agent if you are on the VPN

    # step 1: try to load a saved agent to avoid having to re-auth
    if @authenticated_agent == nil and Rails.env.development? # 
      load_agent
      
      # check to see if agent is valid, otherwise clear it 
      @authenticated_agent = nil unless valid_agent?( @authenticated_agent )
    end
    
    # Step 2: if loading failed then will authenticate a new session
    @authenticated_agent ||= authenticate
  end
  
  def post( url, param_hash={} )
    begin     
      res = authenticated_agent.post(url, param_hash)
      res.body
    rescue
      raise "Failed to connect. Are you on VPN?"
      nil
    end
  end
  
  def get( url, param_hash={} )
    begin     
      res = authenticated_agent.get(url, param_hash)
      res.body
    rescue
      raise "Failed to connect. Are you on VPN?"
      nil
    end
  end
  
  # private
  # returns the newly authenticated agent
  def authenticate
    puts "==AUTHENTICATING EXTRANET=="
    agent = new_secure_agent
    page = agent.get('https://extranet.uphs.upenn.edu') #connect to extranet
    agent.page.forms.first.username = @username # login username for extranet
    agent.page.forms.first.password = @pw # login pw
    agent.page.forms.first.submit # submits login request

    if agent.page.forms.first.checkbox_with(:name =>'postfixSID') #if another extranet session is open, it will ask you to close it or continue. If tow are open, you have to close one. This line looks for checkboxes and closes one session if they are present
      agent.page.forms.first.checkbox.check
    end
    btn = agent.page.forms.first.submit_button?('btnContinue') #finds the continue button
    agent.page.forms.first.submit(btn) # submits it to confirm login
    save_agent if Rails.env.development?
    return agent
  end
  
  def new_secure_agent
    Mechanize.new{|a| a.ssl_version, a.verify_mode = 'TLSv1', OpenSSL::SSL::VERIFY_NONE}
  end
  
  def save_agent
    authenticated_agent.cookie_jar.save_as 'penn_extranet_cookie_jar', :session => true, :format => :yaml
  end
  
  # mainly for testing purposes, because in production it should not need to be called explicitly
  def load_agent
    @authenticated_agent = saved_agent
  end
  
  def saved_agent
    if File.exists?("penn_extranet_cookie_jar")
      puts "==Loaded saved agent=="
      agent = new_secure_agent
      agent.cookie_jar.load('penn_extranet_cookie_jar') 
      agent 
    else
      puts "No saved agent that is valid"
      nil
    end
  end
end