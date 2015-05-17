Promise = require 'bluebird'
_ = require 'lodash'

class Instance
  constructor: (@value) ->
  toObject: -> @value

class ObjectInstance extends Instance
  constructor: ->
    @instances = {}
  set: (key, value) ->
    @instances[key] = value
  getInstance: (key) ->
    @instances[key]
  toObject: ->
    out = {}
    out[key] = value.toObject() for key, value of @instances
    out

class ArrayInstance extends Instance
  constructor: (@model, @length = 0) ->
    @instances = {}
  getInstance: (index) ->
    index = parseInt(index)
    @instances[index] ? @model[index % @model.length]
  set: (index, value) ->
    index = parseInt(index)
    @instances[index] = value
  toObject: ->
    out = []
    for index in [0...@length]
      out.push @getInstance(index).toObject()
    out

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
    @stage().toObject()
  createAsync: (args...) ->
    callback = args.pop() # there should always be a callback
    optionalDefinition = args.shift() # there may or may not be an optional definition
    return @factory(optionalDefinition).createAsync(callback) if optionalDefinition?
    @stageAsync().then((instance) -> instance.toObject()).asCallback(callback)

  # Private:
  initialize: -> [@definitions] = @args
  stage: ->
    @definitions.reduce ((instance, definition) -> definition.stage(instance)), new ObjectInstance()
  stageAsync: ->
    instance = new ObjectInstance()
    reducer = (memo, definition) -> definition.stageAsync(memo)
    Promise.reduce(@definitions, reducer, instance)

  # it's awkward that these following are instance methods, but it means they'll
  # always be available even if a subclass gets exported
  async: (resolver) -> Promise.fromNode(resolver)

class IdentityDefinition extends Definition
  initialize: -> [@identity] = @args
  stage: -> new Instance(@identity)

class ArrayDefinition extends Definition
  initialize: -> [@modelArray] = @args
  stage: ->
    new ArrayInstance(@modelArray.map((value) -> new Instance value), @modelArray.length)

class DotNotationObjectDefinition extends Definition
  initialize: ->
    object = @args[0]
    @paths = Object.keys(object).map (path) ->
      new DotNotationPathDefinition(path, object[path])
  stage: (instance) ->
    instance ?= new ObjectInstance()
    @paths.reduce ((memo, definition) -> definition.stage(memo)), instance
    instance
  stageAsync: (instance) ->
    instance ?= new ObjectInstance()
    reducer = (memo, definition) -> definition.stageAsync(memo)
    Promise.reduce(@paths, reducer, instance)

class DotNotationPathDefinition extends Definition
  initialize: ->
    [fullPath, descendantDefinition] = @args
    fullPath = fullPath.replace /\[(.+?)\]/g, '.$1' # prefer dot notation instead of bracket notation
    [fullPath, @param, childPath] = fullPath.match /^(.+?)(?:\.(.*))?$/
    @childDefinition =
      if @param.match /\[\]$/
        @param = @param.substring(0, @param.length - 2)
        new DotNotationArrayLengthDefinition descendantDefinition
      else if childPath
        new DotNotationPathDefinition(childPath, descendantDefinition)
      else
        Definition.new descendantDefinition
  stage: (instance) ->
    instance ?= new ObjectInstance()
    instance.set(@param, @childDefinition.stage(instance.getInstance @param))
    instance
  stageAsync: (instance) ->
    instance ?= new ObjectInstance()
    @childDefinition.stageAsync(instance.getInstance @param).then (valueInstance) =>
      instance.set(@param, valueInstance)
      instance

class DotNotationArrayLengthDefinition extends Definition
  initialize: -> [@length] = @args
  stage: (instance) ->
    instance.length = @length
    instance

class FunctionDefinition extends Definition
  initialize: -> [@function] = @args
  stage: (args...) -> new Instance(@function(args...))

class AsyncDefinition extends Definition
  initialize: -> [@promise] = @args
  stage: -> throw new Error("Cannot synchronously stage this object!")
  stageAsync: (args...) ->
    @promise.then (definition) -> Definition.new(definition).stage(args...)

module.exports = new Factory([])
