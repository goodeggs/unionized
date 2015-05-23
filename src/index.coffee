Promise = require 'bluebird'
faker = require 'faker'
Factory = require './factory'
EmbeddedArrayDefinition = require './embedded_array_definition'
MongooseFactory = require './mongoose_factory'

# it's awkward that these following are instance methods, but it means they'll
# always be available even if a subclass gets exported
Factory::array = (args...) -> new EmbeddedArrayDefinition(args...)
Factory::async = (resolver) ->
  (args...) -> Promise.fromNode(resolver.bind @, args...)
Factory::enum = (array) -> -> faker.random.array_element array
Factory::mongooseFactory = MongooseFactory.createFromModel

module.exports = new Factory([])
