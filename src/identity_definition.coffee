Definition = require './definition'
Instance = require './instance'

module.exports = class IdentityDefinition extends Definition
  initialize: -> [@identity] = @args

  buildInstance: -> new Instance(@identity)

