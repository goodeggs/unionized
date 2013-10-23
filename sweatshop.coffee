_ = require 'lodash'

factories = {}
parseArgs = (args) ->
  switch args.length
    when 1 then [callback] = args
    when 2 then [attrs, callback] = args
  {attrs, callback}

class Factory
  constructor: (@model, @factoryFn) ->
  build: (args...) ->
    {attrs, callback} = parseArgs args
    attrs = _.clone attrs ? {}

    @factoryFn.call attrs, =>
      result = if @model
        Sweatshop.createInstanceOf @model, attrs
      else
        _.merge {}, attrs
      _.defer callback, null, result if callback?

  create: (args...) ->
    {attrs, callback} = parseArgs args
    @build attrs, (err, result) ->
      Sweatshop.store result, callback

module.exports = Sweatshop =
  define: (args...) ->
    name = args.shift() if typeof args[0] is 'string'

    switch args.length
      when 1 then [factoryFn] = args
      when 2 then [model, factoryFn] = args

    factory = new Factory model, factoryFn
    factories[name] = factory if name?

    factory

  get: (name) ->
    factories[name] or throw "Unknown factory `#{name}`"

  create: (name, args...) ->
    Sweatshop.get(name).create args...

  build: (name, args...) ->
    Sweatshop.get(name).build args...

  createInstanceOf: (model, attrs) -> new model attrs

  store: (model, callback) ->
    console.log arguments
    if _.isFunction model.save
      model.save callback
    else
      callback null, model
