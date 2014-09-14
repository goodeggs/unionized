_ = require './helpers'
dotpath = require './dotpath'

module.exports = class FactoryDefinition
  constructor: (attrs = {}, @mode, @args) ->
    @_out = {}
    @_arraySizes = {}
    @_attrPaths = []
    for path, value of attrs
      if path.substr(-2) is '[]'
        @_arraySizes[path.slice 0, -2] = value
      else
        path = dotpath.normalizeSubpath path
        @_attrPaths.push path
        dotpath.set @_out, path, value unless value is undefined

  set: (path, value, options = {}) ->
    return if dotpath.containsSubpath @_attrPaths, path
    options.init ?= yes
    dotpath.set @_out, path, value, options.init
    value

  unset: (path) ->
    dotpath.clear @_out, path

  embed: (path, factory, callback) ->
    return _.defer(callback) if dotpath.containsSubpath @_attrPaths, path
    factory[@mode] (@get(path) ? {}), (err, value) =>
      return callback(err) if err?
      @set path, value
      callback null, value

  setArray: (path, defaultCount, value) ->
    return if dotpath.containsSubpath @_attrPaths, path
    count = @_arraySizes[path] ? defaultCount
    _.times count, (index) => @set "#{path}[#{index}]", value[index % value.length]

  embedArray: (path, defaultCount, factory, callback) ->
    return _.defer(callback) if dotpath.containsSubpath @_attrPaths, path
    count = @_arraySizes[path] ? defaultCount
    embedInstance = (index, done) =>
      @embed "#{path}[#{index}]", factory, done
    _.asyncRepeat count, embedInstance, callback

  get: (path) ->
    dotpath.get @_out, path

  _resolve: ->
    @_out
