###
@name Sweatshop

@fileOverview
Lightweight test factories, optimized for
[CoffeeScript](http://coffeescript.org/).
###

_ = require 'lodash'

class Sweatshop
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

  @returns {object} A plain old JavaScript object
  @async
  ###
  json: (attrs, callback) ->
    attrs = _.clone attrs ? {}
    @factoryFn.call attrs, (err) =>
      return callback err if err?
      @parent.factoryFn.call attrs, (err) =>
        return callback err if err?
        result = _.merge {}, attrs
        callback null, result

  ###
  Creates an instance of the model with the parameters defined when you created
  the factory

  @param {string} [name] - Name of the child factory to use
    (or, just use this one if a name is not supplied)
  @param {object} [factoryParams] - Parameters to send to the factory function

  @returns {object} An instance of the factory model
  @async
  ###
  build: (attrs, callback) ->
    @json attrs, (err, result) =>
      return callback err if err?
      model = @modelInstanceWith result
      callback null, model

  ###
  Creates and saves an instance of the model with the parameters defined when
  you created the factory

  @param {string} [name] - Name of the child factory to use
    (or, just use this one if a name is not supplied)
  @param {object} [factoryParams] - Parameters to send to the factory function

  @returns {object} An instance of the factory model, after `#saveModel` has
    been called on it.
  @async
  ###
  create: (attrs, callback) ->
    @build attrs, (err, model) =>
      return callback err if err?
      @saveModel model, callback

  ###
  Define a sub-factory that shares the factory function, model, and overwritten
  options of this factory. The sub-factory can optionally be referred to by a
  name so it can be accessed later using the `#child` function.

  @param {string} [name] - Optional name of the child factory to use
  
  @returns {Sweatshop} A new factory that descends from the current one.
  ###
  define: (args...) ->
    name =
      if typeof args[0] is 'string'
        args.shift()
      else
        @children.length
    @children[name] = new Sweatshop args..., @

  ###
  Find a descendant factory by name

  @param {string} name - Name of the descendant factory
  
  @returns {Sweatshop} The descendant factory with the supplied name

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
    fnWithSaneArgs = Sweatshop::[fn]
    Sweatshop::[fn] = (args...) ->
      if typeof args[0] is 'string'
        @child(args[0])[fn](args[1..]...)
      else
        callback = args.pop()
        attrs = args.pop()
        fnWithSaneArgs.call @, attrs, callback

module.exports = new Sweatshop _.defer
