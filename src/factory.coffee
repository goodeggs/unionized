Promise = require 'bluebird'
_ = require 'lodash'
HookDefinition = require './hook_definition'
MultiDefinition = require './multi_definition'
ObjectInstance = require './object_instance'
definitionFactory = require './definition_factory'

module.exports = class Factory extends MultiDefinition
  class: Factory

  # Public API:
  factory: (definition) ->
    new (@class) [@definitions..., definitionFactory(definition)]

  create: (overridingDefinition, factoryArguments...) ->
    if overridingDefinition?
      overridingDefinition = definitionFactory overridingDefinition
    factory = if overridingDefinition? then @factory(overridingDefinition) else @
    factory.buildInstance({overridingDefinition, factoryArguments}).toObject()

  createAsync: (args...) ->
    if _.isFunction(args[args.length - 1])
      [args..., callback] = args
    [overridingDefinition, factoryArguments...] = args
    overridingDefinition = definitionFactory overridingDefinition if overridingDefinition?
    factory = if overridingDefinition? then @factory(overridingDefinition) else @
    factory.buildInstanceAsync({overridingDefinition, factoryArguments})
      .then((instance) -> instance.toObjectAsync())
      .asCallback(callback)

  onCreate: (hook) -> @factory(new HookDefinition(hook))

  # Private:
  initialize: ->
    [@definitions] = @args
    # the following allows for code like _.times(3, factory.create) to work. It even works for
    # subclass methods since we're enumerating over all the properties, including inherited
    # ones, to find the methods
    methods = _(@).keysIn().filter((key) => _.isFunction(@[key])).value()
    _.bindAll @, methods
