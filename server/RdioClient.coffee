Rdio = require './lib/rdio'

class natefm.RdioClient
	
	constructor: (@config, @server) ->
		@rdio = new Rdio [@config.rdio.apikey, @config.rdio.secret]
		@repository = @server.repository
	
	getPlaybackToken: (callback) ->
		@_request 'getPlaybackToken', { domain: 'localhost' }, callback
	
	getComments: (callback) ->
		@repository.getObject 'comments', (err, cached) =>
			if not err? and cached? and not @_isExpired(cached)
				log "returning cached data from #{new Date(Number(cached.timestamp))}"
				callback null, JSON.parse(cached.data)
			else
				log "loading new data from rdio"
				@_request 'getActivityStream', { user: @config.rdio.user, scope: 'user' }, (err, result) =>
					if err?
						callback(err, null)
					else
						log "got new data from rdio"
						comments = _.select result.updates, (update) ->
							update.update_type > 5 and update.update_type < 10
						@repository.putObject 'comments',
							timestamp: new Date().valueOf()
							data:      JSON.stringify(comments)
						callback(null, comments)
	
	_isExpired: (cached) ->
		timestamp = Number(cached.timestamp)
		expired   = new Date().valueOf() - (@config.rdio.cacheSec * 1000)
		return timestamp < expired
	
	_request: (method, options, callback) ->
		@rdio.call method, options, (err, response) ->
			if err?
				callback err, null
			else if response.status isnt 'ok'
				callback 'call failed', response.result
			else
				callback null, response.result
