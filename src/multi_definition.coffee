Promise = require 'bluebird'
Definition = require './definition'
ObjectInstance = require './object_instance'

module.exports = class MultiDefinition extends Definition
  buildInstance: (options = {}) ->
    instance = options.instance ? new ObjectInstance(options.overridingDefinition)
    reducer = (memo, definition) ->
      definition.buildInstance
        instance: memo
        overridingDefinition: options.overridingDefinition
        factoryArguments: options.factoryArguments
    @definitions.reduce reducer, instance
    instance

  buildInstanceAsync: (options = {}) ->
    instance = options.instance ? new ObjectInstance(options.overridingDefinition)
    reducer = (memo, definition) ->
      definition.buildInstanceAsync
        instance: memo
        overridingDefinition: options.overridingDefinition
        factoryArguments: options.factoryArguments
    Promise.reduce(@definitions, reducer, instance)
