Promise = require 'bluebird'

module.exports = class Instance
  constructor: (@value) ->
  toObject: -> @value
  toObjectAsync: (args...) -> new Promise (resolve) => resolve(@toObject(args...))
