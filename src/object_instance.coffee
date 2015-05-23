Instance = require './instance'

module.exports = class ObjectInstance extends Instance
  constructor: ->
    @instances = {}
    super()

  setInstance: (key, value) ->
    @instances[key] = value

  getInstance: (key) ->
    @instances[key]

  toObject: ->
    @value = {}
    @value[key] = value.toObject() for key, value of @instances
    super

