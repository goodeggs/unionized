_ = require './helpers'
dotpath = require './dotpath'

module.exports = class FactoryDefinition
  constructor: (@attrs = {}, @mode, @args) ->
    @_out = {}
    @setAttrs() # attrs are set in the beginning so they can be referenced

  setAttrs: ->
    for path, value of @attrs when value isnt undefined
      dotpath.set @_out, path, value

  set: (path, value, options = {}) ->
    return if dotpath.containsSubpath @attrs, path
    options.init ?= yes
    dotpath.set @_out, path, value, options.init
    value

  unset: (path) ->
    dotpath.clear @_out, path

  embed: (path, factory, callback) ->
    return _.defer(callback) if dotpath.containsSubpath @attrs, path
    factory[@mode] @get(path), (err, value) =>
      return callback(err) if err?
      @set path, value
      callback null, value

  embedArray: (path, defaultCount, factory, callback) ->
    callback()

  get: (path) ->
    dotpath.get @_out, path

  _resolve: ->
    @_out
