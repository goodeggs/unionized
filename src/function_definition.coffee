Definition = require './definition'
Instance = require './instance'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args

  buildInstance: (options = {}) ->
    instance = options.instance ? new Instance()
    @_buildDefinitionFromFunction(instance).buildInstance({instance})

  buildInstanceAsync: (options = {}) ->
    instance = options.instance ? new Instance()
    @_buildDefinitionFromFunction(instance).buildInstanceAsync({instance})

  _buildDefinitionFromFunction: (instance) ->
    definitionFactory @function.apply(instance)
