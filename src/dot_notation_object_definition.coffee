Promise = require 'bluebird'
MultiDefinition = require './multi_definition'
DotNotationPathDefinition = require './dot_notation_path_definition'
ObjectInstance = require './object_instance'

module.exports = class DotNotationObjectDefinition extends MultiDefinition
  initialize: ->
    object = @args[0]
    @definitions = Object.keys(object).map (path) ->
      new DotNotationPathDefinition(path, object[path])

