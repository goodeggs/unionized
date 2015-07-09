unionized = require 'unionized'

eventFactory = unionized.factory
  refs:
    userId: '123abc'
    orderId: '345def'

createdEventFactory = eventFactory.factory
  name: 'order.created'

addedItemsEventFactory = eventFactory.factory
  name: 'order.addedItems'

console.log addedItemsEventFactory.create()
