unionized = require 'unionized'

eventFactory = unionized.factory
  name: 'order.created'

console.log eventFactory.create()
