#quips
a leak-plugging layer on top of backbone.js

a basic example can be found here: http://github.com/vistarmedia/quips-example

###Installation
```bash
npm install quips
```

###Authentication
currently, quips will assume a rest resource "/session/" which responds to GET, POST and DELETE requests.
- the GET should return the email (username) and name (friendly name) for a currently logged on session.
- the POST should authenticate a user based on username/password.
- the DELETE should log out the user.