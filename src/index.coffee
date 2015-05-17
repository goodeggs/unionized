Promise = require 'bluebird'
Factory = require './factory'
EmbeddedArrayDefinition = require './embedded_array_definition'

# it's awkward that these following are instance methods, but it means they'll
# always be available even if a subclass gets exported
Factory::async = (resolver, thisArg = null) ->
  (args...) -> Promise.fromNode(resolver.bind thisArg, args...)
Factory::array = (args...) -> new EmbeddedArrayDefinition(args...)

module.exports = new Factory([])
