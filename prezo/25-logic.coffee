unionized = require 'unionized'

eventFactory = unionized.factory ->
  userId = '123abc'
  'refs.userId': userId
  'args.order.user': @get('refs.userId') ? userId

console.log eventFactory.create('refs.userId': 'foobar')
