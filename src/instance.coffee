Promise = require 'bluebird'

module.exports = class Instance
  constructor: (@value) ->
    @hooks = []

  get: -> @value

  calculateValue: -> @value

  calculateValueAsync: ->
    new Promise (resolve) => resolve @calculateValue()

  toObject: ->
    # uses return value of hooks; be careful that hooks return a modified object.
    @hooks.reduce ((memo, hook) -> hook(memo)), @calculateValue()

  toObjectAsync: ->
    @calculateValueAsync().then (value) =>
      Promise.reduce @hooks, ((memo, hook) -> hook(memo)), value
