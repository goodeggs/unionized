Promise = require 'bluebird'
Instance = require './instance'

module.exports = class ArrayInstance extends Instance
  constructor: (@model, @length = 0) ->
    @instances = {}
    super()

  getInstance: (index) ->
    index = parseInt(index)
    return @instances[index] if @instances[index]?
    @instances[index] = @model[index % @model.length].buildInstance()
    @instances[index]

  getInstanceAsync: (index) ->
    if @instances[index]?
      return new Promise (resolve) => resolve(@instances[index])
    @model[index % @model.length].buildInstanceAsync().then (instance) =>
      @instances[index] = instance
      instance

  setInstance: (index, value) ->
    index = parseInt(index)
    if index >= @length
      @length = index + 1
    @instances[index] = value

  calculateValue: ->
    value = []
    for index in [0...@length]
      value.push @getInstance(index).toObject()
    value

  calculateValueAsync: ->
    Promise.map [0...@length], (index) =>
      @getInstanceAsync(index)
        .then (instance) -> instance.toObjectAsync()
