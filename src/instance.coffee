Promise = require 'bluebird'

module.exports = class Instance
  constructor: (@value) ->
    @hooks = []

  get: -> @value

  calculateValue: -> @value

  toObject: ->
    # uses return value of hooks; be careful that hooks return a modified object.
    @hooks.reduce ((memo, hook) -> hook(memo)), @calculateValue()

  toObjectAsync: ->
    Promise.reduce @hooks, ((memo, hook) -> hook(memo)), @calculateValue()
