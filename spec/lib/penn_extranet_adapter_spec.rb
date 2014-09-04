require 'spec_helper'
require 'penn_extranet_adapter.rb'

describe PennExtranetAdapter do
  let(:valid_attributes) { { "username" => "XXXXXXX", "password" => "XXXXXXX" } }
  
  describe "valid_agent?" do
    it "should detect a valid" do
      x = PennExtranetAdapter.new valid_attributes["username"], "x"
      authenticated_agent = x.authenticated_agent
      x.valid_agent?.should == false
    end
  
    it "should detect an invalid agent" do
      x = PennExtranetAdapter.new valid_attributes["username"], valid_attributes["password"]
      authenticated_agent = x.authenticated_agent
      x.valid_agent?.should == true
    end
  end
  
  it "should save and relaod successfully" do
      x = PennExtranetAdapter.new valid_attributes["username"], valid_attributes["password"]
      authenticated_agent = x.authenticated_agent
      x.save_agent
      
      y = PennExtranetAdapter.new "x", "y"
      y.load_agent
      y.valid_agent?.should == true
  end
end