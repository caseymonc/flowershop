request = require "request"
geocoder = require "geocoder"

module.exports = (FlowerShop, User, Delivery) =>

	renderShopPage: (req, res)=>
		FlowerShop.findById req.params.flowershopId, (err, shop)=>
			Delivery.get req.params.flowershopId, (err, deliveries)=>
				console.log deliveries
				return res.render('shop', {shop: shop, title: shop.name, deliveries: deliveries})

	logout: (req, res)=>
		console.log 'Endpoint: Logout'
		if req.session?.shop_user?
			delete req.session.shop_user

		if req.session?.shop?
			delete req.session.shop
		#req.session.destroy()
		return res.redirect '/'

	login: (req, res)=>
		console.log 'Endpoint: Login Shop'
		return res.redirect "/" unless (req.body.username? and req.body.password)
		data = {username: req.body.username, password: req.body.password}
		User.findWithUsername data, (err, user)=>

			return res.redirect '/' if not user or err?
			req.session.shop_user = user
			console.log 'User: ' + JSON.stringify user
			if not user.flowershopId?
				return res.redirect '/'
			FlowerShop.findById user.flowershopId, (err, shop)=>
				return res.redirect '/' if err? or not shop?
				req.session.shop = shop
				console.log "Redirect /shop/" + user.flowershopId
				return res.redirect '/shop/' + user.flowershopId

	create: (req, res)=>
		console.log 'Endpoint: Create'
		if not req.body.username? or 
		not req.body.password?
			return res.redirect "/"
		geocoder.geocode req.body.address, (err, data)=>
			return res.redirect "/" if err
			return res.redirect "/" unless data?.results[0]?.geometry?.location
			location = data.results[0].geometry.location
			data = {name: req.body.name, phone: req.body.phone, address: req.body.address, pos: [location.lng, location.lat]}
			FlowerShop.findOrCreate data, (err, shop, created)=>
				console.log err if err?
				req.session.shop = shop
				console.log {error: "Not Created 1"} unless created
				return res.redirect "/" unless created
				data = {username: req.body.username, password: req.body.password}
				data.shop = shop
				data.username
				User.findOrCreateWithShop data, (err, user, created)=>
					console.log {error: "Not Created 2"} unless created
					return res.redirect "/" unless created
					return res.redirect '/shop/' + shop._id
		

