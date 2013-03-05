mongoose = require 'mongoose'
Schema = mongoose.Schema

# User Model
module.exports = (db) ->

  DriverSchema = new Schema {
    uri: String
  }


  DriverSchema.statics.getAllRegisteredDrivers = (cb) ->
    @find({uri: {$ne: null}}).exec cb



  Driver = db.model "Driver", DriverSchema