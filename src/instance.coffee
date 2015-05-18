Promise = require 'bluebird'

module.exports = class Instance
  constructor: (@value) ->
    @hooks = []

  toObject: ->
    # uses return value of hooks; be careful that hooks return a modified object.
    @hooks.reduce(((memo, hook) -> hook(memo)), @value)

  toObjectAsync: (args...) -> new Promise (resolve) => resolve(@toObject(args...))
