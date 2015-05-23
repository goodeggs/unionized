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

  create: (overrides) ->
    return @factory(overrides).create() if overrides?
    @buildInstance().toObject()

  createAsync: (args...) ->
    overrides = args[0] if _.isObject(args[0]) and not _.isFunction(args[0])
    callback = args[args.length - 1] if _.isFunction(args[args.length - 1])
    return @factory(overrides).createAsync(callback) if overrides?
    @buildInstanceAsync().then((instance) -> instance.toObjectAsync()).asCallback(callback)

  onCreate: (hook) -> @factory(new HookDefinition(hook))

  # Private:
  initialize: -> [@definitions] = @args

  buildInstance: ->
    @definitions.reduce ((instance, definition) -> definition.buildInstance(instance)), new ObjectInstance()

  buildInstanceAsync: ->
    instance = new ObjectInstance()
    reducer = (memo, definition) -> definition.buildInstanceAsync(memo)
    Promise.reduce(@definitions, reducer, instance)

