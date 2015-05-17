Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class AsyncDefinition extends Definition
  initialize: -> [@promise] = @args
  stage: -> throw new Error("Cannot synchronously stage this object!")
  stageAsync: (args...) ->
    @promise.then (definition) -> definitionFactory(definition).stage(args...)

