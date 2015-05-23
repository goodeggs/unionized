Definition = require './definition'
DotNotationArrayLengthDefinition = require './dot_notation_array_length_definition'
DotNotationPathDefinition = require './dot_notation_path_definition'
DotNotation = require './dot_notation'
ObjectInstance = require './object_instance'
definitionFactory = require './definition_factory'

module.exports = class DotNotationPathDefinition extends Definition
  initialize: ->
    [pathString, descendantDefinition] = @args
    @dotNotation = new DotNotation(pathString)
    @childDefinition =
      if @dotNotation.isArrayLength()
        new DotNotationArrayLengthDefinition descendantDefinition
      else if @dotNotation.isLeaf()
        definitionFactory descendantDefinition
      else
        new DotNotationPathDefinition(@dotNotation.childPathString(), descendantDefinition)

  buildInstance: (instance) ->
    instance ?= new ObjectInstance()
    instance.setInstance(@dotNotation.param(), @childDefinition.buildInstance(instance.getInstance @dotNotation.param()))
    instance

  buildInstanceAsync: (instance) ->
    instance ?= new ObjectInstance()
    @childDefinition.buildInstanceAsync(instance.getInstance @dotNotation.param()).then (valueInstance) =>
      instance.setInstance(@dotNotation.param(), valueInstance)
      instance

