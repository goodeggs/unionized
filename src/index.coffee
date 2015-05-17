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
      else if _.isArray(definition)
        ArrayDefinition
      else if _.isPlainObject(definition)
        DotNotationObjectDefinition
      else
        IdentityDefinition
    new subclass(arguments...)
  isDefinition: -> true
  constructor: (@args...) -> @initialize?()
  stage: -> throw new Error("Subclasses must implement `stage`!")
  stageAsync: (args...) -> new Promise (resolve) => resolve(@stage(args...))

class Factory extends Definition
  # Public API:
  factory: (definition) ->
    new Factory [@definitions..., Definition.new(definition)]
  create: (optionalDefinition) ->
    return @factory(optionalDefinition).create() if optionalDefinition?
    @stage()
  createAsync: (args...) ->
    callback = args.pop() # there should always be a callback
    optionalDefinition = args.shift() # there may or may not be an optional definition
    return @factory(optionalDefinition).createAsync(callback) if optionalDefinition?
    @stageAsync().asCallback(callback)

  # Private:
  initialize: -> [@definitions] = @args
  stage: ->
    @definitions.reduce ((memo, definition) -> definition.stage(memo)), {}
  stageAsync: ->
    object = {}
    reducer = (builtObject, definition) -> definition.stageAsync(builtObject)
    Promise.reduce(@definitions, reducer, object)

  # it's awkward that these following are instance methods, but it means they'll
  # always be available even if a subclass gets exported
  async: (resolver) -> Promise.fromNode(resolver)

class IdentityDefinition extends Definition
  initialize: -> [@identity] = @args
  stage: -> @identity

class ArrayDefinition extends Definition
  initialize: ->
    [@modelArray] = @args
    @length = @modelArray.length
  stage: ->
    out = []
    out.__definition = @
    out

class DotNotationObjectDefinition extends Definition
  initialize: ->
    object = @args[0]
    @paths = Object.keys(object).map (path) ->
      new DotNotationPathDefinition(path, object[path])
  stage: (object) ->
    object ?= {}
    @paths.reduce ((memo, definition) -> definition.stage(memo)), object
    object
  stageAsync: (object) ->
    object ?= {}
    reducer = (builtObject, definition) -> definition.stageAsync(builtObject)
    Promise.reduce(@paths, reducer, object)

class DotNotationPathDefinition extends Definition
  initialize: ->
    [fullPath, descendantDefinition] = @args
    [fullPath, @param, childPath] = fullPath.match /^(.+?)(?:\.(.*))?$/
    @childDefinition = if childPath
      new DotNotationPathDefinition(childPath, descendantDefinition)
    else
      Definition.new descendantDefinition
  stage: (object) ->
    object ?= {}
    object[@param] = @childDefinition.stage(object[@param])
    object
  stageAsync: (object) ->
    object ?= {}
    @childDefinition.stageAsync(object[@param]).then (result) =>
      object[@param] = result
      object

class FunctionDefinition extends Definition
  initialize: -> [@function] = @args
  stage: (args...) -> @function(args...)

class AsyncDefinition extends Definition
  initialize: -> [@promise] = @args
  stage: -> throw new Error("Cannot synchronously stage this object!")
  stageAsync: (args...) ->
    @promise.then (definition) -> Definition.new(definition).stage(args...)

module.exports = new Factory([])
