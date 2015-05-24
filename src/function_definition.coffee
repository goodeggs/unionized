Definition = require './definition'
Instance = require './instance'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args

  buildInstance: (instance, args...) ->
    instance ?= new Instance()
    @_buildDefinitionFromFunction(instance, args).buildInstance(instance, args)

  buildInstanceAsync: (instance, args...) ->
    instance ?= new Instance()
    @_buildDefinitionFromFunction(instance, args).buildInstanceAsync(instance, args)

  _buildDefinitionFromFunction: (instance, args) ->
    definitionFactory @function.apply(instance, args)
