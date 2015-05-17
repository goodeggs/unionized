Promise = require 'bluebird'
_ = require 'lodash'
Definition = require './definition'
EmbeddedArrayDefinition = require './embedded_array_definition'
ObjectInstance = require './object_instance'
definitionFactory = require './definition_factory'

module.exports = class Factory extends Definition
  # Public API:
  factory: (definition) ->
    new Factory [@definitions..., definitionFactory(definition)]
  create: (optionalDefinition) ->
    return @factory(optionalDefinition).create() if optionalDefinition?
    @stage().toObject()
  createAsync: (args...) ->
    optionalDefinition = args[0] if _.isObject(args[0]) and not _.isFunction(args[0])
    callback = args[args.length - 1] if _.isFunction(args[args.length - 1])
    return @factory(optionalDefinition).createAsync(callback) if optionalDefinition?
    @stageAsync().then((instance) -> instance.toObjectAsync()).asCallback(callback)

  # it's awkward that these following are instance methods, but it means they'll
  # always be available even if a subclass gets exported
  async: (resolver, thisArg = null) ->
    (args...) -> Promise.fromNode(resolver.bind thisArg, args...)
  array: (args...) -> new EmbeddedArrayDefinition(args...)

  # Private:
  initialize: -> [@definitions] = @args
  stage: ->
    @definitions.reduce ((instance, definition) -> definition.stage(instance)), new ObjectInstance()
  stageAsync: ->
    instance = new ObjectInstance()
    reducer = (memo, definition) -> definition.stageAsync(memo)
    Promise.reduce(@definitions, reducer, instance)

