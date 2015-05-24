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
  orders: type: [ type: mongoose.Schema.ObjectId, ref: 'Order' ], index: true, required: true

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

  it 'can create routes, stops, and orders from the same factory', (done) ->
    orderFactory = unionized.mongooseFactory(Order)

    stopFactory = unionized.mongooseFactory(Stop).onCreate (stop) ->
      Promise.all stop.orders.map (orderId) ->
        orderFactory.createAndSave _id: orderId
      .then ->
        stop

    routeFactory = unionized.mongooseFactory(Route).onCreate (route) ->
      Promise.all route.stops.map (stopId) ->
        stopFactory.createAndSave _id: stopId
      .then ->
        route

    routeFactory.createAndSave()
      .then ->
        Promise.all([Route.find(), Stop.find(), Order.find()])
      .then ([routes, stops, orders]) ->
        expect(routes).to.have.length 1
        expect(stops).to.have.length 2
        expect(orders).to.have.length 4
        done()

  it 'provides default locations for different stop types', ->
    stopFactory = unionized.mongooseFactory(Stop).factory ->
      'location.name': switch @get('type')
        when 'delivery' then '7419 Park Drive'
        when 'pickup' then 'Good Eggs Foodhub'
        when 'backhaul' then 'Three Babes Bakeshop'
        else 'Minas Morgul'

    expect(stopFactory.create()).to.have.deep.property 'location.name', 'Minas Morgul'
    expect(stopFactory.create(type: 'delivery')).to.have.deep.property 'location.name', '7419 Park Drive'
