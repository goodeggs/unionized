unionized = require 'unionized'
ObjectId = require('mongoose').Types.ObjectId

orderItemFactory = unionized.factory
  productId: -> ObjectId()
  subtotal: 599
  'product.vendor.name': 'Stepladder Ranch'

eventFactory = unionized.factory
  name: 'order.created'
  'args.order.items': [ orderItemFactory ]

console.log eventFactory.create('args.order.items[]': 5).args.order
