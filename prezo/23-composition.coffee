unionized = require 'unionized'

orderItemFactory = unionized.factory
  subtotal: 599
  'product.vendor.name': 'Stepladder Ranch'

eventFactory = unionized.factory
  name: 'order.created'
  'args.order.items': [ orderItemFactory ]

console.log eventFactory.create().args.order
