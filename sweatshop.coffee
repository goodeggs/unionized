_ = require 'lodash'

factories = {}

module.exports = Sweatshop =
  define : (name, args...) ->
    switch args.length
      when 1 then [factory] = args
      when 2 then [model, factory] = args

    factories[name] = { model, factory }

  create : (name, args...) ->
    switch args.length
      when 1 then [callback] = args
      when 2 then [attrs, callback] = args

    { model, factory } = factories[name] or throw "Unknown factory `#{name}`"
    attrs ?= {}
    attrs = _.clone attrs

    factory.call attrs, ->
      result = if model
        Sweatshop.createInstanceOf model, attrs
      else
        _.merge {}, attrs

      Sweatshop.store result, callback

  createInstanceOf : (model, attrs) -> new model attrs

  store : (model, callback) ->
    if _.isFunction model.save
      model.save callback
    else
      callback null, model
