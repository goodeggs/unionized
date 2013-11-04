_ = require 'lodash'

class Sweatshop
  constructor: (args...) ->
    @parent = args.pop() if typeof _(args).last() is 'object'
    @factoryFn = args.pop()
    @model = args.pop() ? Object
    @children = []

  json: (attrs, callback) ->
    attrs = _.clone attrs ? {}
    @factoryFn.call attrs, (err) =>
      return callback err if err?
      @parent.factoryFn.call attrs, (err) =>
        return callback err if err?
        result = _.merge {}, attrs
        callback null, result

  build: (attrs, callback) ->
    @json attrs, (err, result) =>
      return callback err if err?
      model = @modelInstanceWith result
      callback null, model

  create: (attrs, callback) ->
    @build attrs, (err, model) =>
      return callback err if err?
      @saveModel model, callback

  define: (args...) ->
    name =
      if typeof args[0] is 'string'
        args.shift()
      else
        @children.length
    @children[name] = new Sweatshop args..., @

  child: (name) ->
    @children[name] or throw "Unknown factory `#{name}`"

  modelInstanceWith: (attrs) ->
    new @model attrs

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
