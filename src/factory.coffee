Promise = require 'bluebird'
_ = require 'lodash'
Definition = require './definition'
HookDefinition = require './hook_definition'
ObjectInstance = require './object_instance'
definitionFactory = require './definition_factory'

module.exports = class Factory extends Definition
  class: Factory

  # Public API:
  factory: (definition) ->
    new (@class) [@definitions..., definitionFactory(definition)]

  create: (overridingDefinition) ->
    if overridingDefinition?
      overridingDefinition = definitionFactory overridingDefinition
    factory = if overridingDefinition? then @factory(overridingDefinition) else @
    factory.buildInstance({overridingDefinition}).toObject()

  createAsync: (args...) ->
    if _.isObject(args[0]) and not _.isFunction(args[0])
      overridingDefinition = definitionFactory args[0]
    if _.isFunction(args[args.length - 1])
      callback = args[args.length - 1]
    factory = if overridingDefinition? then @factory(overridingDefinition) else @
    factory.buildInstanceAsync({overridingDefinition})
      .then((instance) -> instance.toObjectAsync())
      .asCallback(callback)

  onCreate: (hook) -> @factory(new HookDefinition(hook))

  # Private:
  initialize: -> [@definitions] = @args

  buildInstance: (options = {}) ->
    instance = new ObjectInstance(options.overridingDefinition)
    reducer = (memo, definition) ->
      definition.buildInstance
        instance: memo
        overridingDefinition: options.overridingDefinition
    @definitions.reduce reducer, instance

  buildInstanceAsync: (options = {}) ->
    instance = new ObjectInstance(options.overridingDefinition)
    reducer = (memo, definition) ->
      definition.buildInstanceAsync
        instance: memo
        overridingDefinition: options.overridingDefinition
    Promise.reduce @definitions, reducer, instance

