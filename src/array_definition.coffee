ArrayInstance = require './array_instance'
Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class ArrayDefinition extends Definition
  initialize: ->
    [modelArray] = @args
    @length = modelArray.length
    @modelArray = modelArray.map (definition) -> definitionFactory(definition)

  buildInstance: ->
    new ArrayInstance(@modelArray, @length)
