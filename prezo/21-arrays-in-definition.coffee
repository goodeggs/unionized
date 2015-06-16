unionized = require 'unionized'

eventFactory = unionized.factory
  name: 'order.created'
  'args.order':
    items: [
      subtotal: 599
      'product.vendor.name': 'Stepladder Ranch'
    ]

console.log eventFactory.create().args.order
