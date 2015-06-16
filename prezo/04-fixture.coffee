require './test_setup'
orderEventHandler = require './order_event_handler'

it 'handles an order.created event', ->
  event = require './event_fixture.json'
  result = orderEventHandler(event)
  expect(result).to.be.ok
