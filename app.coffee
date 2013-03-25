express = require 'express'
fs = require 'fs'
MemoryStore = require('express').session.MemoryStore
Mongoose = require 'mongoose'
DeliveryModel = require './model/Delivery'
UserModel = require './model/User'
DriverModel = require './model/Driver'
FlowerShopModel = require './model/FlowerShop'
request = require "request"
https = require('https')
event = require('events')
EventEmitter = new event.EventEmitter()
EventController = require("./control/EventController")(EventEmitter)


DB = process.env.DB || 'mongodb://localhost:27017/shop'
db = Mongoose.createConnection DB



User = UserModel db
Driver = DriverModel db
FlowerShop = FlowerShopModel db
Delivery = DeliveryModel db


DriverControl = require './control/DriverController'
DriverController = new DriverControl(User, Driver)

FlowerShopControl = require('./control/FlowerShopController')
FlowerShopController = new FlowerShopControl FlowerShop, User, Delivery

DeliveryControl = require('./control/DeliveryController')
DeliveryController = new DeliveryControl Delivery, FlowerShop, User, Driver, EventController

mongomate = require('mongomate')('mongodb://localhost')

PORT = 3080
exports.createServer = ->

	app = express()		

	app.configure ->
		app.use(express.cookieParser())
		app.use(express.bodyParser())
		app.use(express.methodOverride())
		app.use(express.session({ secret: 'keyboard cat' }))
		app.use('/db', mongomate);
		
		app.set('view engine', 'jade')
		app.use(app.router)
		app.use(express.static(__dirname + "/public"))
		app.set('views', __dirname + '/public')
		app.use('/javascript', express.static(__dirname + "/public/javascript"))


	app.get '/', (req, res)->
		res.render('index', {title: "FlowerShop/Driver"})

	app.post '/profile/:user_id/uri', (req, res)->
		DriverController.registerUri req, res

	app.post '/profile/:user_id/uri/delete', (req, res)->
		DriverController.unregisterUri req, res

	app.get '/shop/:flowershopId', (req, res)->
		FlowerShopController.renderShopPage req, res

	app.get '/delivery/:delivery_id/bid/:bid_id/accept', (req, res)->
		DeliveryController.acceptBid req, res

	app.get '/delivery/:delivery_id/pickup', (req, res)->
		DeliveryController.pickedUp req, res
			 
	app.post "/create/flowershop", (req, res)->
		FlowerShopController.create req, res

	app.post "/login/flowershop", (req, res)->
		FlowerShopController.login req, res

	app.post "/shop/:flowershopId/delivery", (req, res)->
		DeliveryController.createDelivery req, res

	app.get "/logout", (req, res)->
		FlowerShopController.logout req, res

	app.post '/event', (req, res)->
		EventController.handleEvent req, res
		res.send "OK"


	EventEmitter.on "rfq:bid_available", (body)=>
		DeliveryController.addBid body

	EventEmitter.on 'rfq:driver_ready', (body)=>
		DriverController.registerDriver body

	EventEmitter.on 'rfq:driver_done', (body)=>
		DriverController.unRegisterDriver body



	# final return of app object
	app

if module == require.main
	app = exports.createServer()
	app.listen PORT
	console.log "Running Foursquare Service on port: " + PORT
