require './test_setup'
orderEventHandler = require './order_event_handler'

it 'handles an order.created event', ->
  event = require './event_fixture.json'
  result = orderEventHandler(event)
  expect(result).to.be.ok

it 'handles an order.created event with a different user', ->
  event = require './event_fixture.json'
  event.refs.userId = '53197f3007c2080000002a09'
  event.args.order.user = '53197f3007c2080000002a09'

  result = orderEventHandler(event)
  expect(result).to.be.ok
  expect(result)
