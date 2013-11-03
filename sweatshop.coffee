_ = require 'lodash'

factories = {}
parseArgs = (args) ->
  switch args.length
    when 1 then [callback] = args
    when 2 then [attrs, callback] = args
  {attrs, callback}

module.exports = class Sweatshop
  constructor: (@model = Object, @factoryFn) ->

  json: (args...) ->
    {attrs, callback} = parseArgs args
    attrs = _.clone attrs ? {}

    @factoryFn.call attrs, (err) =>
      return _.defer callback, err if err?
      result = _.merge {}, attrs
      _.defer callback, null, result

  build: (args...) ->
    {attrs, callback} = parseArgs args
    @json attrs, (err, result) =>
      return _.defer callback, err if err?
      result = Sweatshop.createInstanceOf @model, result
      _.defer callback, null, result

  create: (args...) ->
    {attrs, callback} = parseArgs args
    @build attrs, (err, result) ->
      return _.defer callback, err if err?
      Sweatshop.store result, callback

Sweatshop.define = (args...) ->
  name = args.shift() if typeof args[0] is 'string'

  switch args.length
    when 1 then [factoryFn] = args
    when 2 then [model, factoryFn] = args

  factory = new Sweatshop model, factoryFn
  factories[name] = factory if name?

  factory

Sweatshop.get = (name) ->
  factories[name] or throw "Unknown factory `#{name}`"

Sweatshop.create = (name, args...) ->
  Sweatshop.get(name).create args...

Sweatshop.build = (name, args...) ->
  Sweatshop.get(name).build args...

Sweatshop.createInstanceOf = (model, attrs) ->
  new model attrs

Sweatshop.store = (model, callback) ->
  if _.isFunction model.save
    model.save callback
  else
    _.defer callback, null, model
