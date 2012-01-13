Rdio = require '../vendor/rdio'

class natefm.RdioClient
	
	constructor: (@config) ->
		@rdio = new Rdio [@config.apikey, @config.secret]
	
	getComments: (callback) ->
		@_request 'getActivityStream', { user: @config.user, scope: 'user' }, callback, (result) ->
			_.select result.updates, (update) ->
				update.update_type > 5 and update.update_type < 10
	
	_request: (method, options, callback, process) ->
		@rdio.call method, options, (err, response) ->
			if err?
				callback err, null
			else if response.status isnt 'ok'
				callback 'call failed', response
			else
				callback null, process(response.result)