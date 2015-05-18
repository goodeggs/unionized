_ = require 'lodash'
Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args

  buildInstance: (args...) ->
    definitionFactory(@function(_.compact(args)...)).buildInstance(args...)

  buildInstanceAsync: (args...) ->
    definitionFactory(@function(_.compact(args)...)).buildInstanceAsync(args...)
