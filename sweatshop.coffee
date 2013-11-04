_ = require 'lodash'

parseArgs = (args) ->
  name = args.shift() if typeof _(args).first() is 'string'
  switch args.length
    when 1 then [callback] = args
    when 2 then [attrs, callback] = args
  {name, attrs, callback}

class Sweatshop
  constructor: (args...) ->
    @parent = args.pop() if typeof _(args).last() is 'object'
    @factoryFn = args.pop()
    @model = args.pop() ? Object
    @children = []

  json: (args...) ->
    {name, attrs, callback} = parseArgs args
    return @get(name).json(attrs, callback) if name?
    attrs = _.clone attrs ? {}

    @factoryFn.call attrs, (err) =>
      return _.defer callback, err if err?
      result = _.merge {}, attrs
      _.defer callback, null, result

  build: (args...) ->
    {name, attrs, callback} = parseArgs args
    return @get(name).build(attrs, callback) if name?
    @json attrs, (err, result) =>
      return _.defer callback, err if err?
      model = @modelInstanceWith result
      _.defer callback, null, model

  create: (args...) ->
    {name, attrs, callback} = parseArgs args
    return @get(name).create(attrs, callback) if name?
    @build attrs, (err, model) =>
      return _.defer callback, err if err?
      @saveModel model, callback

  define: (args...) ->
    name =
      if typeof _(args).first() is 'string'
        args.shift()
      else
        @children.length
    @children[name] = new Sweatshop args...

  get: (name) ->
    @children[name] or throw "Unknown factory `#{name}`"

  modelInstanceWith: (attrs) ->
    new @model attrs

  saveModel: (model, callback) ->
    if _.isFunction model.save
      model.save callback
    else
      _.defer callback, null, model

module.exports = new Sweatshop _.defer
