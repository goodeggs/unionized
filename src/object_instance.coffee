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

  toObject: ->
    @value = {}
    @value[key] = value.toObject() for key, value of @instances
    super

