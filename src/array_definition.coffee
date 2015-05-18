ArrayInstance = require './array_instance'
Definition = require './definition'
Promise = require 'bluebird'
definitionFactory = require './definition_factory'

module.exports = class ArrayDefinition extends Definition
  initialize: ->
    [modelArray] = @args
    @length = modelArray.length
    @modelArray = modelArray.map (definition) -> definitionFactory(definition)

  buildInstance: ->
    instances = @modelArray.map((definition) -> definition.buildInstance())
    new ArrayInstance(instances, @length)

  buildInstanceAsync: ->
    Promise.map(@modelArray, (definition) -> definition.buildInstanceAsync())
      .then (instances) => new ArrayInstance(instances, @length)

