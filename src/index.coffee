Promise = require 'bluebird'
_ = require 'lodash'

class Unionized
  constructor: (@definitions) ->
  factory: (definition) ->
    new Unionized [@definitions..., Definition.new(definition)]
  create: (optionalDefinition) ->
    return @factory(optionalDefinition).create() if optionalDefinition?
    @definitions.reduce ((memo, definition) -> definition.apply(memo)), {}
  createAsync: (args...) ->
    callback = args.pop() # there should always be a callback
    optionalDefinition = args.shift() # there may or may not be an optional definition
    return @factory(optionalDefinition).createAsync(callback) if optionalDefinition?
    object = {}
    reducer = (builtObject, definition) -> definition.applyAsync(builtObject)
    Promise.reduce(@definitions, reducer, object).asCallback(callback)

  # it's awkward that these following are instance methods, but it means they'll
  # always be available even if a subclass gets exported
  async: (resolver) -> Promise.fromNode(resolver)

class Definition
  @new: (definition) ->
    subclass =
      if _.isFunction(definition)
        FunctionDefinition
      else if _.isFunction(definition.create) # factory!
        FactoryDefinition
      else if _.isFunction(definition.then) # promise!
        AsyncDefinition
      else if _.isPlainObject(definition)
        DotNotationObjectDefinition
      else
        IdentityDefinition
    new subclass(arguments...)
  constructor: (@args...) -> @initialize?()
  apply: -> throw new Error("Subclasses must implement `apply`!")
  applyAsync: (args...) -> new Promise (resolve) => resolve(@apply(args...))

class FactoryDefinition extends Definition
  initialize: -> [@factory] = @args
  apply: -> @factory.create()
  applyAsync: -> @factory.createAsync()

class IdentityDefinition extends Definition
  initialize: -> [@identity] = @args
  apply: -> @identity

class DotNotationObjectDefinition extends Definition
  initialize: ->
    object = @args[0]
    @paths = Object.keys(object).map (path) ->
      new DotNotationPathDefinition(path, object[path])
  apply: (object) ->
    object ?= {}
    @paths.reduce ((memo, definition) -> definition.apply(memo)), object
    object
  applyAsync: (object) ->
    object ?= {}
    reducer = (builtObject, definition) -> definition.applyAsync(builtObject)
    Promise.reduce(@paths, reducer, object)

class DotNotationPathDefinition extends Definition
  initialize: ->
    [fullPath, descendantDefinition] = @args
    [fullPath, @param, childPath] = fullPath.match /^(.+?)(?:\.(.*))?$/
    @childDefinition = if childPath
      new DotNotationPathDefinition(childPath, descendantDefinition)
    else
      Definition.new descendantDefinition
  apply: (object) ->
    object ?= {}
    object[@param] = @childDefinition.apply(object[@param])
    object
  applyAsync: (object) ->
    object ?= {}
    @childDefinition.applyAsync(object[@param]).then (result) =>
      object[@param] = result
      object

class FunctionDefinition extends Definition
  initialize: -> [@function] = @args
  apply: (args...) -> @function(args...)

class AsyncDefinition extends Definition
  initialize: -> [@promise] = @args
  apply: -> throw new Error("Cannot synchronously create this object!")
  applyAsync: (args...) ->
    @promise.then (definition) -> Definition.new(definition).apply(args...)

module.exports = unionized = new Unionized([])
