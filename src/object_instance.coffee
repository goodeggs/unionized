DotNotation = require './dot_notation'
Instance = require './instance'

module.exports = class ObjectInstance extends Instance
  constructor: ->
    @instances = {}
    super()

  setInstance: (key, value) ->
    @instances[key] = value

  getInstance: (key) ->
    @instances[key]

  get: (dotNotationKey) ->
    dotNotation = new DotNotation(dotNotationKey)
    @getInstance(dotNotation.param()).get(dotNotation.childPathString())

  calculateValue: ->
    value = {}
    value[key] = instance.toObject() for key, instance of @instances
    value
