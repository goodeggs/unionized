dotpath = require './dotpath'

module.exports = class FactoryDefinition
  constructor: (@attrs = {}, @mode, @args) ->
    @_out = {}
    @attrKeys = Object.keys @attrs
    @setAttrs() # attrs should be set in the beginning so they can be referenced

  setAttrs: ->
    for key, value of @attrs when value isnt undefined
      dotpath.set @_out, key, value

  set: (key, value, options = {}) ->
    options.init ?= yes

    # if something is already set in an attr, don't clobber that.
    for subpath in dotpath.subpaths key
      return @attrs[subpath] if subpath in @attrKeys

    dotpath.set @_out, key, value, options.init

    value

  unset: (key) ->
    dotpath.clear @_out, key

  embed: (key, factory, callback) ->
    factory[@mode] @get(key), (err, value) =>
      return callback(err) if err?
      @set key, value
      callback null, value

  embedArray: (key, defaultCount, factory, callback) ->
    callback()

  get: (key) ->
    dotpath.get @_out, key

  resolve: ->
    @_out
