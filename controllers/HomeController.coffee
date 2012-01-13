class natefm.HomeController extends natefm.Controller
	
	@controller 'home'
	
	index: (req, res) ->
		@rdio.getComments (err, comments) ->
			res.render 'index.eco',
				comments: comments