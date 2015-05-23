_ = require 'lodash'
Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args

  buildInstance: (args...) ->
    @_buildDefinitionFromFunction(args).buildInstance(args...)

  buildInstanceAsync: (args...) ->
    @_buildDefinitionFromFunction(args).buildInstanceAsync(args...)

  _buildDefinitionFromFunction: (args) ->
    definitionFactory @function.apply(null, _.compact args)
