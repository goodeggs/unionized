Promise = require 'bluebird'
_ = require 'lodash'

class Definition
  @new: (definition) ->
    return definition if definition.isDefinition?()
    subclass =
      if _.isFunction(definition)
        FunctionDefinition
      else if _.isFunction(definition.then) # promise!
        AsyncDefinition
      else if _.isPlainObject(definition)
        DotNotationObjectDefinition
      else
        IdentityDefinition
    new subclass(arguments...)
  isDefinition: -> true
  constructor: (@args...) -> @initialize?()
  create: -> throw new Error("Subclasses must implement `create`!")
  createAsync: (args...) -> new Promise (resolve) => resolve(@create(args...))

class Factory extends Definition
  initialize: -> [@definitions] = @args
  factory: (definition) ->
    new Factory [@definitions..., Definition.new(definition)]
  create: (optionalDefinition) ->
    return @factory(optionalDefinition).create() if optionalDefinition?
    @definitions.reduce ((memo, definition) -> definition.create(memo)), {}
  createAsync: (args...) ->
    callback = args.pop() # there should always be a callback
    optionalDefinition = args.shift() # there may or may not be an optional definition
    return @factory(optionalDefinition).createAsync(callback) if optionalDefinition?
    object = {}
    reducer = (builtObject, definition) -> definition.createAsync(builtObject)
    Promise.reduce(@definitions, reducer, object).asCallback(callback)

  # it's awkward that these following are instance methods, but it means they'll
  # always be available even if a subclass gets exported
  async: (resolver) -> Promise.fromNode(resolver)

class IdentityDefinition extends Definition
  initialize: -> [@identity] = @args
  create: -> @identity

class DotNotationObjectDefinition extends Definition
  initialize: ->
    object = @args[0]
    @paths = Object.keys(object).map (path) ->
      new DotNotationPathDefinition(path, object[path])
  create: (object) ->
    object ?= {}
    @paths.reduce ((memo, definition) -> definition.create(memo)), object
    object
  createAsync: (object) ->
    object ?= {}
    reducer = (builtObject, definition) -> definition.createAsync(builtObject)
    Promise.reduce(@paths, reducer, object)

class DotNotationPathDefinition extends Definition
  initialize: ->
    [fullPath, descendantDefinition] = @args
    [fullPath, @param, childPath] = fullPath.match /^(.+?)(?:\.(.*))?$/
    @childDefinition = if childPath
      new DotNotationPathDefinition(childPath, descendantDefinition)
    else
      Definition.new descendantDefinition
  create: (object) ->
    object ?= {}
    object[@param] = @childDefinition.create(object[@param])
    object
  createAsync: (object) ->
    object ?= {}
    @childDefinition.createAsync(object[@param]).then (result) =>
      object[@param] = result
      object

class FunctionDefinition extends Definition
  initialize: -> [@function] = @args
  create: (args...) -> @function(args...)

class AsyncDefinition extends Definition
  initialize: -> [@promise] = @args
  create: -> throw new Error("Cannot synchronously create this object!")
  createAsync: (args...) ->
    @promise.then (definition) -> Definition.new(definition).create(args...)

module.exports = new Factory([])
