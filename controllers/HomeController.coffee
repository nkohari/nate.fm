class natefm.HomeController extends natefm.Controller
	
	@controller 'home'
	
	index: (req, res) ->
		res.render 'index.eco'