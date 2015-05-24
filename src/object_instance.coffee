DotNotation = require './dot_notation'
Instance = require './instance'

module.exports = class ObjectInstance extends Instance
  constructor: (@overridingDefinition) ->
    @instances = {}
    super()

  setInstance: (key, value) ->
    @instances[key] = value

  getInstance: (key) ->
    @instances[key]

  get: (dotNotationKey) ->
    dotNotation = new DotNotation(dotNotationKey)
    overriddenInstance = if @overridingDefinition
      @overridingDefinition.buildInstance(@)
    else
      @
    instance = overriddenInstance.instances[dotNotation.param()]
    instance?.get(dotNotation.childPathString())

  calculateValue: ->
    value = {}
    value[key] = instance.toObject() for key, instance of @instances
    value
