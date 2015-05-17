Promise = require 'bluebird'

module.exports = class Instance
  constructor: (@value) ->
  toObject: -> @value
  toObjectAsync: -> new Promise (resolve) => resolve(@toObject())
