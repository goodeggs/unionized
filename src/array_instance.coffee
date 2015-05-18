Instance = require './instance'

module.exports = class ArrayInstance extends Instance
  constructor: (@model, @length = 0) ->
    @instances = {}
  getInstance: (index) ->
    index = parseInt(index)
    @instances[index] ? @model[index % @model.length]
  set: (index, value) ->
    index = parseInt(index)
    @instances[index] = value
  toObject: ->
    out = []
    for index in [0...@length]
      out.push @getInstance(index).toObject()
    out

