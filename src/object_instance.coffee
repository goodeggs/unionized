Instance = require './instance'

module.exports = class ObjectInstance extends Instance
  constructor: ->
    @instances = {}
  set: (key, value) ->
    @instances[key] = value
  getInstance: (key) ->
    @instances[key]
  toObject: ->
    out = {}
    out[key] = value.toObject() for key, value of @instances
    out

