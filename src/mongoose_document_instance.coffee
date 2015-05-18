ObjectInstance = require './object_instance'

module.exports = class MongooseDocumentInstance extends ObjectInstance
  constructor: (@Model) -> super()

  toObject: (options = {}) ->
    leanDoc = super
    return leanDoc if options.lean
    new @Model leanDoc

  toObjectAsync: (options = {}) ->
    super(arguments...).then (document) ->
      return document if not options.save
      return document.save().then -> document

