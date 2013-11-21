# API Explorer

API Explorer is a tool that reads a specification and creates a console where developers can test their own web services.

## Features

- Loads API specification from a file or a string
- Multiple HTTP methods supported: GET, POST, PUT, DELETE
- Syntax highlighting for Json, XML and HTTP responses.
- History of requests/responses
- Specify HTTP headers
- Specify Request parameters
- Show description of the web service, which can be used as a documentation of the web services.
- Supports HTTP basic authentication and HMAC-SHA1 hash authentication.

## Precondition
Given that it makes a request to the same server, it requires a multi-threaded server. On this example we will use 'thin' but it should work with 'unicorn' as well.


## Configure thin server on threaded mode (it should work with unicorn also) 

Add thin to the Gemfile.
```
gem 'thin', '~> 1.6.1'
```

Bundle install 
```
bundle install
```


Set thread safe mode in development.rb (or the right environment) 

```
config.thread_safe!
```

Test the server by running it with:
```
thin start --threaded
```

## Install the gem

Add the gem to the Gemfile. 

```
gem 'api_explorer'
```

Create a file named ws_specification.json (or any name you desire) and place it on /lib. An example can be:

```
{ "methods": [ 
	  { "name": "Users index", 
	    "url": "v1/users", 
	    "description": "The index of users", 
	    "method": "GET", 
	    "parameters": [{"name": "API_TOKEN"}] 
	  }, 
	  { "name": "User login", 
	    "url": "v1/users/login", 
	    "description": "Users login", 
	    "method": "POST", 
	    "parameters": [{"name": "API_TOKEN"}, {"name": "email"}, {"name": "password"}] 
	  } 
  ] 
}
```

Create an initializer in /config/initializers/api_explorer.rb with the following content:

```
ApiExplorer::use_file = true 
ApiExplorer::json_path = ‘lib/ws_specification.json’
```

Another option can be:
```
ApiExplorer::use_file = false   
ApiExplorer::json_string = { ... - Web services specification - ....}
```

And install all dependencies:

```
bundle install
```

And finally mount the engine on config/routes.rb
```
mount ApiExplorer::Engine => '/api_explorer'
```

That's it. Its ready to go. 


## Run

Start thin

```
thin start --threaded
```

And go to 

```
http://localhost:3000/api_explorer
```

## Contribute

- Fork project
- Add features
- Send pull request

## Next improvements

- Better error handling
- Test with unicorn
- More authentication methods
- Support absolute URLs to test 3rd party APIs.

## License

See LICENSE file for details

## Author
Developed at [TopTier labs](http://www.toptierlabs.com/ "TopTier labs")