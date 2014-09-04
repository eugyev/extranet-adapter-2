# Intro
This is an adapter used to connect to the University of Pennsylvania's extranet, given a valid username and password. It returns an authenticated Mechanize agent, allowing the user to access any pages that an authenticated user could access.

# Usage
## Creation
```
p = PennExtranetAdapter.new( user, pw )
```
## Getting a page
```
source = p.get( url, params )
source = p.post( url, params )
```
## Directly accessing the authenticated mechanize object
```
o = p.authenticated_agent
```
