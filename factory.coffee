_ = require 'lodash'

factories = {}

module.exports = Factory =
  define : (name, args...) ->
    switch args.length
      when 1 then [ factory ] = args
      when 2 then [ model, factory ] = args

    factories[name] = { model, factory }

  create : (name, args...) ->
    switch args.length
      when 1 then [ callback ] = args
      when 2 then [ attrs, callback ] = args

    { model, factory } = factories[name] or throw "Unknown factory `#{name}`"
    attrs ?= {}
    attrs = _.clone attrs

    await factory.apply attrs, [ defer() ]

    result = if model
      Factory.createInstanceOf model, attrs
    else
      _.merge {}, attrs

    Factory.store result, callback

  createInstanceOf : (model, attrs) -> new model attrs

  store : (model, callback) ->
    if _.isFunction model.save
      await model.save defer err, model
      throw err if err?

    callback model
