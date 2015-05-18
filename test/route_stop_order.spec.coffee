expect = require('chai').expect
moment = require 'moment'
mongoose = require './mongoose'
unionized = require '..'
Promise = require 'bluebird'

Route = mongoose.model 'Route',
  foodhubSlug: type: String, required: true
  fulfillmentDay: type: String, required: true
  orderCount: type: Number, required: true
  stops: type: [ type: mongoose.Schema.ObjectId, ref: 'Stop' ], index: true, required: true
  viamente:
    driver: type: String      # letter code
    departureTime: type: Date
    totalMileage: type: Number

Stop = mongoose.model 'Stop',
  key:
    type: String
    index: unique: true
    required: true
  type: type: String, enum: ['delivery', 'pickup', 'backhaul', 'unknown'], default: 'unknown'
  startAt: type: Date, required: true
  endAt: type: Date, required: true
  tzid: type: String, required: true
  location: name: type: String, required: true
  orders: type: [ type: mongoose.Schema.ObjectId, ref: 'Order' ], index: true

Order = mongoose.model 'Order',
  fulfillmentId: type: mongoose.Schema.ObjectId, required: true, index: unique: true
  userId: type: mongoose.Schema.ObjectId, required: true
  customer:
    name: type: String, required: true
    email: type: String
  status: type: String, enum: ['undelivered', 'delivered', 'missed'], default: 'undelivered', required: true

describe 'mongoose route, stop, and order tests', ->
  beforeEach (done) ->
    Promise
      .all [ Route.remove(), Stop.remove(), Order.remove() ]
      .then -> done()
      .catch (error) -> done(error)

  it 'can create a route using the unionized factories', (done) ->
    unionized.mongooseFactory(Route).createAndSave 'stops[]': 3, (error, route) ->
      return done(error) if error
      expect(route.stops).to.have.length 3
      done()
