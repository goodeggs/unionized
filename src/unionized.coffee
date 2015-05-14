###
@name Unionized

@fileOverview
Lightweight test factories, optimized for
[CoffeeScript](http://coffeescript.org/).
###

async = require 'async'
_ = require './helpers'
FactoryDefinition = require './factory_definition'

class Unionized
  #
  # new Unionized(model, factoryFn, parent)
  # new Unionized(model, factoryFn)
  # new Unionized(factoryFn, parent)
  # new Unionized(factoryFn)
  #
  constructor: (args...) ->
    if typeof _.last(args) is 'object'
      @parent = args.pop()

    @factoryFn = args.pop()

    # infer from lack of callback that it's meant to be run synchronously.
    if @factoryFn.length is 0
      @_synchronous = true
      if @parent? and not @parent._synchronous
        throw new Error("Cannot define a synchronous factory as a child of an asynchronous factory")

    else if @factoryFn.length > 1
      throw new Error "Factory functions should take 1 or 0 arguments."

    @model = args.pop()
    @children = []


  ###
  Builds a plain, JSON-compatible object from your factory.
  sync or async.
  ###
  _json: (definition, callback) ->
    if @_synchronous and callback?
      throw new Error "Synchronous factory .json does not accept a callback"
    else if not @_synchronous and not callback?
      throw new Error "Asynchronous factory .json requires a callback"

    # get factory fns from factory and all relatives
    # TODO refactor this loop?
    factoryFns = if @factoryFn then [@factoryFn] else []
    child = @
    while child.parent?
      factoryFns.unshift(child.parent.factoryFn) if child.parent.factoryFn?
      child = child.parent

    # already guarded above that synchronous factory can't have async in its parents,
    # but vice-versa is ok.
    if callback?
      stack = factoryFns.map (factoryFn) ->
        if factoryFn.length is 1   # async
          return (cb) ->
            # factoryFn can introspect `@args` for special cases.
            factoryFn.call definition, cb
        else
          return (cb) ->
            try    # sync parent
              factoryFn.call definition
              cb()
            catch err
              cb err

      async.series stack, (err) ->
        if err? then callback err
        else callback null, definition._resolve()

    else  # all sync
      factoryFns.forEach (factoryFn) ->
        factoryFn.call definition, definition.args
      return definition._resolve()


  ###
  Creates an instance of the model with the parameters defined when you created
  the factory

  @param {string} [name] - Name of the child factory to use
    (or, just use this one if a name is not supplied)
  @param {object} [factoryParams] - Parameters to send to the factory function

  @returns {object} An instance of the factory model

  only async!
  ###
  _build: (definition, callback) ->
    if @_synchronous
      throw new Error "Cannot call `build` on a synchronous factory."
    @_json definition, (err, result) =>
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
  _create: (definition, callback) ->
    if @_synchronous
      throw new Error "Cannot call `create` on a synchronous factory."
    @_build definition, (err, model) =>
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

  - IMPT: factoryFn should take either a callback (1 arg), or no arguments.

  @returns {Unionized} A new factory that descends from the current one.
  ###
  define: (args..., factoryFn) ->
    if typeof factoryFn isnt 'function'
      throw new Error "Factory definition needs a factory function"

    name =
      if typeof args[0] is 'string' then args.shift()
      else @children.length

    @children[name] = new Unionized args..., factoryFn, @


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
    if @model?
      new @model attrs
    # delegate up the tree until there's a model.
    else if @parent?
      @parent.modelInstanceWith(attrs)
    else
      attrs

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
      _.defer model, callback


for fnName in ['json', 'build', 'create']
  do (fnName) ->
    fnWithAllArgs = Unionized::["_#{fnName}"]

    # any of these are valid:
    #  fn(name, attrs, callback)
    #  fn(attrs, callback)
    #  fn(callback)
    #  fn(attrs, extra1, extra2, callback)   (see factories_with_arguments.spec)
    #  fn(attrs, extra1, extra2)
    #
    Unionized::[fnName] = (args...) ->
      if typeof args[0] is 'string'
        childName = args.shift()
        instance = @child(childName)
      else
        instance = @

      # callback is necessary for async factories. otherwise can be undefined.
      # (each method has its own handling/requirements for callback.)
      if typeof _.last(args) is 'function'
        callback = args.pop()

      attrs = args.shift()

      # any remaining `args` are arbitrary, for introspection in factoryFn.
      definition = new FactoryDefinition attrs, fnName, args

      fnWithAllArgs.call instance, definition, callback


# create default, (synchronous) factory for extending.
baseFactory = new Unionized (->)

module.exports = baseFactory