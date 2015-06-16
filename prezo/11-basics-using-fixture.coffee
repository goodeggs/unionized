unionized = require 'unionized'

eventFactory = unionized.factory require('./event_fixture.json')

event = eventFactory.create()
console.log event
