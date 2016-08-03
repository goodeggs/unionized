Definition = require './definition'
Instance = require './instance'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args

  buildInstance: (options = {}) ->
    instance = options.instance ? new Instance()
    @_buildDefinitionFromFunction(instance, options.factoryArguments).buildInstance({instance, factoryArguments: options.factoryArguments})

  buildInstanceAsync: (options = {}) ->
    instance = options.instance ? new Instance()
    @_buildDefinitionFromFunction(instance, options.factoryArguments).buildInstanceAsync({instance, factoryArguments: options.factoryArguments})

  _buildDefinitionFromFunction: (instance, factoryArguments) ->
    definitionFactory @function.apply(instance, factoryArguments)
