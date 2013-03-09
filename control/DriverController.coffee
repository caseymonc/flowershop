request = require "request"

module.exports = (User, Driver) =>
	
	registerDriver: (body)=>
		console.log "Test"
		Driver.registerDriver body.uri, (err, driver)=>


	unRegisterDriver: (body)=>
		Driver.unRegisterDriver body.uri



