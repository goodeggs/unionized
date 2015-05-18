Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class AsyncDefinition extends Definition
  initialize: -> [@promise] = @args

  buildInstance: -> throw new Error("Cannot synchronously buildInstance this object!")

  buildInstanceAsync: (args...) ->
    @promise.then (definition) -> definitionFactory(definition).buildInstance(args...)

