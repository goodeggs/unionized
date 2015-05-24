Promise = require 'bluebird'
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

  getInstanceAsync: (key) ->
    new Promise (resolve) => resolve(@getInstance key)

  get: (dotNotationKey) ->
    dotNotation = new DotNotation(dotNotationKey)
    overriddenInstance = if @overridingDefinition
      @overridingDefinition.buildInstance(instance: @)
    else
      @
    instance = overriddenInstance.instances[dotNotation.param()]
    instance?.get(dotNotation.childPathString())

  calculateValue: ->
    value = {}
    value[key] = instance.toObject() for key, instance of @instances
    value

  calculateValueAsync: ->
    reducer = (memo, key) =>
      @instances[key].toObjectAsync().then (value) =>
        memo[key] = value
        memo
    Promise.reduce Object.keys(@instances), reducer, {}
