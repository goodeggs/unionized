Promise = require 'bluebird'
Definition = require './definition'
DotNotationPathDefinition = require './dot_notation_path_definition'
ObjectInstance = require './object_instance'

module.exports = class DotNotationObjectDefinition extends Definition
  initialize: ->
    object = @args[0]
    @paths = Object.keys(object).map (path) ->
      new DotNotationPathDefinition(path, object[path])

  buildInstance: (options = {}) ->
    instance = options.instance ? new ObjectInstance()
    @paths.reduce ((memo, definition) -> definition.buildInstance(instance: memo)), instance
    instance

  buildInstanceAsync: (options = {}) ->
    instance = options.instance ? new ObjectInstance()
    reducer = (memo, definition) -> definition.buildInstanceAsync(instance: memo)
    Promise.reduce(@paths, reducer, instance)

