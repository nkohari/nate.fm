window.natefm = {}

class natefm.Client
	
	@start: (config) ->
		window.natefm = new this(config)
	
	constructor: (@config) ->
		@rdio = rdio = $('#rdioswf').rdio(@config.playbackToken)
		
		$('.rdio-item').live 'click', (event) ->
			key = $(event.currentTarget).data('key')
			rdio.play(key)