_ = require 'lodash'

class Unionized
  constructor: (@definitions) ->
  factory: (definition) ->
    new Unionized [@definitions..., Definition.new(definition)]
  create: (optionalDefinition) ->
    return @factory(optionalDefinition).create() if optionalDefinition?
    @definitions.reduce ((memo, definition) -> definition.apply(memo)), {}

class Definition
  @new: (definition) ->
    subclass = if _.isPlainObject(definition)
      DotNotationObjectDefinition
    else if _.isFunction(definition)
      FunctionDefinition
    else
      IdentityDefinition
    new subclass(arguments...)
  constructor: (@args...) -> @initialize?()
  apply: (object) ->
    throw new Error("Subclasses must implement `apply`!")

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

class FunctionDefinition extends Definition
  initialize: -> [@function] = @args
  apply: (args...) -> @function(args...)

module.exports = unionized = new Unionized([])
