class natefm.Controller
	
	@controller: (name) ->
		natefm.Server.controllers[name] = new this()