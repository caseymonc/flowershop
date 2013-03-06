request = require "request"

module.exports = (User, Driver) =>
	
	registerUri: (body)=>
		Driver driver = new Driver {uri: body.uri}
		driver.save

	unregisterUri: (body)=>
		Driver.unRegisterDriver body.uri



