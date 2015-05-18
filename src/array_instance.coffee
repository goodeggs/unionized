Instance = require './instance'

module.exports = class ArrayInstance extends Instance
  constructor: (@model, @length = 0) ->
    @instances = {}
    super()

  getInstance: (index) ->
    index = parseInt(index)
    @instances[index] ? @model[index % @model.length]

  set: (index, value) ->
    index = parseInt(index)
    @instances[index] = value

  toObject: ->
    @value = []
    for index in [0...@length]
      @value.push @getInstance(index).toObject()
    super

