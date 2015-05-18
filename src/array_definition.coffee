ArrayInstance = require './array_instance'
Definition = require './definition'
Promise = require 'bluebird'
definitionFactory = require './definition_factory'

module.exports = class ArrayDefinition extends Definition
  initialize: ->
    [modelArray] = @args
    @length = modelArray.length
    @modelArray = modelArray.map (definition) -> definitionFactory(definition)
  stage: ->
    instances = @modelArray.map((definition) -> definition.stage())
    new ArrayInstance(instances, @length)
  stageAsync: ->
    Promise.map(@modelArray, (definition) -> definition.stageAsync())
      .then (instances) => new ArrayInstance(instances, @length)

