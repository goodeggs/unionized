unionized = require 'unionized'
ObjectId = require('mongoose').Types.ObjectId

eventFactory = unionized.factory
  name: 'order.created'
  'args.order':
    items: [
      productId: -> ObjectId()
      'product.vendor.name': 'Stepladder Ranch'
    ]

console.log eventFactory.create('args.order.items[5].productId': 'nerps').args.order
