fs      = require 'fs'
util    = require 'util'
assets  = require 'connect-assets'
express = require 'express'
eco     = require 'eco'

class natefm.Server

	@controllers: []

	constructor: (@config, @routes) ->
		@rdio = new natefm.RdioClient(@config.rdio)
		@app = express.createServer()

		@app.register '.eco', eco
		
		@app.use assets(src: 'client')
		@app.use express.bodyParser()
		@app.use express.cookieParser()
		
		if @config.http.debug
			@app.use express.errorHandler
				showStack:      true
				dumpExceptions: true

		@_loadControllers()
		@_loadRoutes()
		
	start: ->
		@app.listen @config.http.port, =>
			addr = @app.address()
			log "listening on http://#{addr.address}:#{addr.port}"
	
	_loadControllers: ->
		require('../controllers/' + filename) for filename in fs.readdirSync 'controllers'
		for name, controller of natefm.Server.controllers
			controller.server = this
			controller.config = @config
			controller.rdio   = @rdio
			log "loaded #{name} controller"
	
	_loadRoutes: ->
		for controller, entries of @routes
			for action, value of entries
				[verb, url] = value.split(/\s+/, 2)
				@_registerRoute controller, action, verb, url
	
	_registerRoute: (controller, action, verb, url) ->
			impl = natefm.Server.controllers[controller]
			if not controller? then throw new Error("route defined for non-existent controller #{controller}")
			
			actiondef = impl[action]
			if not actiondef? then throw new Error("route defined for non-existent action #{action} on controller #{controller}")
			
			if actiondef instanceof Function
				handler = actiondef
			else
				unless actiondef.handler instanceof Function
					throw new Error("missing or invalid handler defined for action #{action} on controller #{controller}")
				handler = actiondef.handler
			
			middleware = @_getMiddleware controller, action, actiondef, impl
			@app[verb] url, middleware, _.bind(handler, impl)
			
			log "registered route: [#{verb}] #{url} -> #{controller}.#{action}"
		
	_getMiddleware: (controller, action, actiondef, impl) ->
		
		middleware = []
		
		addFilter = (filter) ->
			func = impl[filter]
			if not func? then throw new Error("missing filter #{filter} for action #{action} on controller #{controller}")
			middleware.push _.bind(func, impl)
			sys.puts "[rubicon] registered filter #{filter} for action #{action} on controller #{controller}"
		
		if impl.__filters?
			addFilter(filter) for filter in impl.__filters
			
		if actiondef.filters?
			filters = if actiondef.filters instanceof Array then actiondef.filters else [actiondef.filters]
			addFilter(filter) for filter in filters
			
		return middleware