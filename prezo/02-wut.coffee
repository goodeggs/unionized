# What is Unionized for??

require './test_setup'
orderEventHandler = require './order_event_handler'

it 'handles an order.created event', ->
  result = orderEventHandler(name: 'order.created')
  expect(result).to.be.ok
