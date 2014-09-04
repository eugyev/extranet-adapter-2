# Usage
## Creation
  p = PennExtranetAdapter.new( user, pw )

## Getting a page
  source = p.get( url, params )
  source = p.post( url, params )

## Directly accessing the authenticated mechanize object
  o = p.authenticated_agent

