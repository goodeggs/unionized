Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args

  buildInstance: (instance, args...) ->
    @_buildDefinitionFromFunction(instance, args).buildInstance(instance, args)

  buildInstanceAsync: (instance, args...) ->
    @_buildDefinitionFromFunction(instance, args).buildInstanceAsync(instance, args)

  _buildDefinitionFromFunction: (instance, args) ->
    definitionFactory @function.apply(instance, args)
