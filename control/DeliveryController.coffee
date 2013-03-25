
module.exports = (Delivery, FlowerShop, User, Driver, EventController) =>
	createDelivery: (req, res)=>
		FlowerShop.findById req.params.flowershopId, (err, shop)=>
			data = req.body
			data.flowerShopId = "#{shop._id}"
			Delivery.create data, (err, delivery)=>
				data.shopAddress = shop.address
				data.delivery_id = delivery._id
				data.lat = shop.pos[1];
				data.lon = shop.pos[0];
				data.uri = req.protocol + "://" + req.get('host') + "/event"
				data.radius = 10
				Driver.getAllRegisteredDrivers (err, drivers)=>
					return res.redirect '/shop/#{req.session.shop._id/test}' if err?
					#EventController.sendExternalEvent driver.uri, "rfq", "delivery_ready", data for driver in drivers
					EventController.sendExternalEvent "http://localhost:3040/event", "rfq", "delivery_ready", data
					res.redirect "/shop/#{req.session.shop._id}"

	addBid: (body)=>
		if not body?.bid? or not body?.driverUri? or not body?.driverName? or not body?.delivery_id?
			console.log "Wrong Params Sent: " + JSON.stringify body
			return

		delivery_id = body.delivery_id
		data = 
			bid: body.bid
			driverUri: body.driverUri
			driverName: body.driverName

		Delivery.addBid delivery_id, data, (err, delivery)=>
			return console.log err if err
			return

	acceptBid: (req, res)=>
		bid_id = req.params.bid_id
		delivery_id = req.params.delivery_id
		Delivery.acceptBid delivery_id, bid_id, (err, delivery)=>
			return res.redirect "/shop/#{req.session.shop._id}" if err
			data = {}
			EventController.sendExternalEvent "http://localhost:3040/event", "rfq", "bid_awarded", normalize delivery
			res.redirect "/shop/#{req.session.shop._id}"

	pickedUp: (req, res)=>
		delivery_id = req.params.delivery_id
		Delivery.pickedUp delivery_id, (err, delivery)=>
			return res.redirect "/shop/#{req.session.shop._id}" if err
			EventController.sendExternalEvent "http://localhost:3040/event", "delivery", "picked_up", normalize delivery
			res.redirect "/shop/#{req.session.shop._id}"


base = ()-> [
  'delivery_id'
  'flowerShopId'
  'address'
  'pickupTime'
  'deliveryTime'
  'bids'
  'pickedUp'
]

normalize = (delivery) ->
  result = {}
  fields = base()
  for key in fields
    if key is 'delivery_id' and delivery._id?
      result[key] = delivery._id
    else if delivery[key]?
      result[key] = delivery[key]
  return result
