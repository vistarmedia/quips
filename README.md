#quips
a leak-plugging layer on top of backbone.js

a basic example can be found here: http://github.com/vistarmedia/quips-example

[![Build Status](https://api.travis-ci.org/vistarmedia/quips.png?branch=master)](http://travis-ci.org/vistarmedia/quips?branch=master)

###Installation
```bash
npm install quips
```

###Authentication
currently, quips will assume a rest resource "/session/" which responds to GET, POST and DELETE requests.
- the GET should return the email (username) and name (friendly name) for a currently logged on session.
- the POST should authenticate a user based on username/password.
- the DELETE should log out the user.

###Block UI Integration
you may create a global blocking UI overlay from any view by calling block() on that view. unblocking is just as simple by calling unblock().

###Sticky Sidebar Integration
any DetailView can be passed the sticky:true option to its constructor. this will make sure it stays visible during scrolling.
