###
@name Unionized

@fileOverview
Lightweight test factories, optimized for
[CoffeeScript](http://coffeescript.org/).
###

_ = require 'lodash'
dot = require 'dot-component'

class Unionized
  constructor: (args...) ->
    @parent = args.pop() if typeof _(args).last() is 'object'
    @factoryFn = args.pop()
    @model = args.pop() ? Object
    @children = []

  ###
  Builds a plain, JSON-compatible object from your factory

  @param {string} [name] - Name of the child factory to use
    (or, just use this one if a name is not supplied)
  @param {object} [factoryParams] - Parameters to send to the factory function
  @param {object} [overrides] - Overrides to apply after the factory function
    is done

  @returns {object} A plain old JavaScript object
  @async
  ###
  json: (attrs, overrides, mode, callback) ->
    attrs = _.clone attrs ? {}
    @factoryFn.call attrs, mode, (err) =>
      return callback err if err?
      @parent.factoryFn.call attrs, (err) =>
        return callback err if err?
        result = _.merge {}, attrs
        dot.set result, key, val, true for key, val of overrides
        callback null, result

  ###
  Creates an instance of the model with the parameters defined when you created
  the factory

  @param {string} [name] - Name of the child factory to use
    (or, just use this one if a name is not supplied)
  @param {object} [factoryParams] - Parameters to send to the factory function
  @param {object} [overrides] - Overrides to apply after the factory function
    is done

  @returns {object} An instance of the factory model
  @async
  ###
  build: (attrs, overrides, mode, callback) ->
    @json attrs, overrides, mode, (err, result) =>
      return callback err if err?
      model = @modelInstanceWith result
      callback null, model

  ###
  Creates and saves an instance of the model with the parameters defined when
  you created the factory

  @param {string} [name] - Name of the child factory to use
    (or, just use this one if a name is not supplied)
  @param {object} [factoryParams] - Parameters to send to the factory function
  @param {object} [overrides] - Overrides to apply after the factory function
    is done

  @returns {object} An instance of the factory model, after `#saveModel` has
    been called on it.
  @async
  ###
  create: (attrs, overrides, mode, callback) ->
    @build attrs, overrides, mode, (err, model) =>
      return callback err if err?
      @saveModel model, callback

  ###
  Define a sub-factory that shares the factory function, model, and overwritten
  options of this factory. The sub-factory can optionally be referred to by a
  name so it can be accessed later using the `#child` function.

  @param {string} [name] - Optional name of the child factory to use
  @param {object} [model] - Optional model for the child factory to use
  @param {function} factoryFn - Factory function for the child factory. Will be
    applied before the factory function of the parent factory.
  
  @returns {Unionized} A new factory that descends from the current one.
  ###
  define: (args...) ->
    name =
      if typeof args[0] is 'string'
        args.shift()
      else
        @children.length
    @children[name] = new Unionized args..., @

  ###
  Find a descendant factory by name

  @param {string} name - Name of the descendant factory
  
  @returns {Unionized} The descendant factory with the supplied name

  @throws Complains if there is no descendant factory with the supplied name
  ###
  child: (name) ->
    @children[name] or throw "Unknown factory `#{name}`"

  ###
  Create a new instance of the factory model, given a set of attributes

  @param {object} attrs A set of attributes to pass to the factory model

  @returns {object} A copy of the factory model with the attributes set
  ###
  modelInstanceWith: (attrs) ->
    new @model attrs

  ###
  Persists a copy of the factory model
 
  @param {object} An instance of the factory model to persist

  @returns {*} Whatever the persistance function for the model returns
  @async
  ###
  saveModel: (model, callback) ->
    if _.isFunction model.save
      model.save callback
    else
      _.defer callback, null, model

for fn in ['json', 'build', 'create']
  do (fn) ->
    fnWithSaneArgs = Unionized::[fn]
    Unionized::[fn] = (args...) ->
      instance = if typeof args[0] is 'string' then @child(args.shift()) else @
      callback = args.pop()
      attrs = args.shift()
      overrides = args.shift() || {}
      mode = args.shift() || fn
      fnWithSaneArgs.call instance, attrs, overrides, mode, callback

module.exports = new Unionized _.defer
