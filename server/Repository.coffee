redis = require 'redis'

class natefm.Repository
	
	constructor: (@config, @server) ->
		@redis = redis.createClient @config.redis.port, @config.redis.host
	
	close: ->
		@redis.quit()
	
	getString: (key, callback) ->
		@redis.get key, callback
	
	putString: (key, value, callback) ->
		@redis.set key, value, callback

	getObject: (key, callback) ->
		@redis.hgetall key, callback
	
	putObject: (key, obj, callback) ->
		@redis.hmset key, obj
