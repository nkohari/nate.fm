window.natefm = {}

class natefm.Client
	
	@start: (config) ->
		window.natefm = new this(config)
	
	constructor: (@config) ->
		@rdio = $('#rdioswf')
		@rdio.rdio(@config.playbackToken)
		@rdio.bind 'ready.rdio', (user) ->
			console.log arguments