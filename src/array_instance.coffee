Instance = require './instance'

module.exports = class ArrayInstance extends Instance
  constructor: (@model, @length = 0) ->
    @instances = {}
    super()

  getInstance: (index) ->
    index = parseInt(index)
    @instances[index] ? @model[index % @model.length]

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
