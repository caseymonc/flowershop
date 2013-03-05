request = require "request"

module.exports = (User, Driver) =>
	
	registerUri: (req, res)=>
		Account.findById req.params.user_id, (err, user)=>
			user.uri = req.body.uri
			user.save (err)=>
				return res.redirect '/profile/' + req.params.user_id

	unregisterUri: (req, res)=>
		Account.findById req.params.user_id, (err, user)=>
			user.uri = undefined
			user.save (err)=>
				return res.redirect '/profile/' + req.params.user_id



