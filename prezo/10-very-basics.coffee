unionized = require 'unionized'

eventFactory = unionized.factory name: 'order.created'

event = eventFactory.create()
console.log event
