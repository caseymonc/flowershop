request = require "request"

module.exports = (User, Driver) =>
	
	registerDriver: (body)=>
		Driver.registerDriver body.uri, (err, driver)=>


	unRegisterDriver: (body)=>
		Driver.unRegisterDriver body.uri



