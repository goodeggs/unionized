Promise = require 'bluebird'

module.exports = class Instance
  constructor: (@value) ->
    @hooks = []
  toObject: ->
    @hooks.reduce(((memo, hook) -> hook(memo)), @value)
  toObjectAsync: (args...) -> new Promise (resolve) => resolve(@toObject(args...))
