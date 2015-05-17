Promise = require 'bluebird'
Definition = require './definition'
DotNotationPathDefinition = require './dot_notation_path_definition'
ObjectInstance = require './object_instance'

module.exports = class DotNotationObjectDefinition extends Definition
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

