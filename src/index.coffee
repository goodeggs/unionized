Promise = require 'bluebird'
Factory = require './factory'
EmbeddedArrayDefinition = require './embedded_array_definition'
MongooseFactory = require './mongoose_factory'

# it's awkward that these following are instance methods, but it means they'll
# always be available even if a subclass gets exported
Factory::array = (args...) -> new EmbeddedArrayDefinition(args...)
Factory::async = (resolver, thisArg = null) ->
  (args...) -> Promise.fromNode(resolver.bind thisArg, args...)
Factory::mongooseFactory = MongooseFactory.createFromModel

module.exports = new Factory([])
