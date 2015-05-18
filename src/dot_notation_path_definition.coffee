Definition = require './definition'
DotNotationArrayLengthDefinition = require './dot_notation_array_length_definition'
DotNotationPathDefinition = require './dot_notation_path_definition'
ObjectInstance = require './object_instance'
definitionFactory = require './definition_factory'

module.exports = class DotNotationPathDefinition extends Definition
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
        definitionFactory descendantDefinition

  buildInstance: (instance) ->
    instance ?= new ObjectInstance()
    instance.set(@param, @childDefinition.buildInstance(instance.getInstance @param))
    instance

  buildInstanceAsync: (instance) ->
    instance ?= new ObjectInstance()
    @childDefinition.buildInstanceAsync(instance.getInstance @param).then (valueInstance) =>
      instance.set(@param, valueInstance)
      instance

