ArrayDefinition = require './array_definition'
definitionFactory = require './definition_factory'

module.exports = class EmbeddedArrayDefinition extends ArrayDefinition
  initialize: ->
    [repeatObject, @length] = @args
    @length ?= 2
    @modelArray = [definitionFactory repeatObject]

