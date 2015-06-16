_ = require 'lodash'

require './test_setup'
orderEventHandler = require './order_event_handler'

generateEvent = ({userId} = {}) ->
  event = _.cloneDeep(require './event_fixture.json')
  if userId?
    event.refs.userId = userId
    event.args.order.user = userId
  event

it 'handles an order.created event', ->
  event = generateEvent()
  result = orderEventHandler(event)
  expect(result).to.be.ok

it 'handles an order.created event with a different user', ->
  event = generateEvent(userId: '53197f3007c2080000002a09')
  result = orderEventHandler(event)
  expect(result).to.be.ok
