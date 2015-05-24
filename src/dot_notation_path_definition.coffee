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

  param: -> @dotNotation.param()

  buildInstance: (options = {}) ->
    instance = options.instance ? new ObjectInstance(options.overridingDefinition)
    childInstance = instance.getInstance @param()
    buildInstanceOptions =
      instance: childInstance
      overridingDefinition: options.overridingDefinition?.objectDefinitionForParam?(@param())
    valueInstance = @childDefinition.buildInstance buildInstanceOptions
    instance.setInstance @param(), valueInstance
    instance

  buildInstanceAsync: (options = {}) ->
    instance = options.instance ? new ObjectInstance(options.overridingDefinition)
    childInstance = instance.getInstance @param()
    buildInstanceOptions =
      instance: childInstance
      overridingDefinition: options.overridingDefinition?.objectDefinitionForParam?(@param())
    @childDefinition.buildInstanceAsync(buildInstanceOptions).then (valueInstance) =>
      instance.setInstance(@param(), valueInstance)
      instance
