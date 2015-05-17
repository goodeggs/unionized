_ = require 'lodash'

module.exports = (definition) ->
  # to avoid circular requires
  ArrayDefinition = require './array_definition'
  AsyncDefinition = require './async_definition'
  DotNotationObjectDefinition = require './dot_notation_object_definition'
  FunctionDefinition = require './function_definition'
  IdentityDefinition = require './identity_definition'

  return definition if definition?.isDefinition?()
  subclass =
    if _.isFunction(definition)
      FunctionDefinition
    else if _.isFunction(definition?.then) # promise!
      AsyncDefinition
    else if _.isArray(definition)
      ArrayDefinition
    else if _.isPlainObject(definition)
      DotNotationObjectDefinition
    else
      IdentityDefinition
  new subclass(arguments...)
