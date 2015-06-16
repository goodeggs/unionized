unionized = require 'unionized'

eventFactory = unionized.factory require('./event_fixture.json')

event = eventFactory.create('args.order.items[1].unit': '~~~~~~~~ CHANGE ONLY THE THINGS THAT MATTER ~~~~~~~~')
console.log event.args.order
