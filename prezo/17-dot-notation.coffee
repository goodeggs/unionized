unionized = require 'unionized'
ObjectId = require('mongoose').Types.ObjectId

eventFactory = unionized.factory
  name: 'order.created'
  refs:
    orderId: -> ObjectId().toString()
    userId: -> ObjectId().toString()

console.log eventFactory.create('refs.orderId': '~~~~~~~~~~~~~~ MAX WAS HERE ~~~~~~~~~~~~')
