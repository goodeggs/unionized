unionized = require 'unionized'

eventFactory = unionized.factory
  name: 'order.created'
  'args.order':
    status: 'placed'
    'deliveryWindow.startAt': '2015-06-03T22:00:00.000Z'
    'deliveryWindow.endAt': '2015-06-04T00:00:00.000Z'

console.log eventFactory.create()
