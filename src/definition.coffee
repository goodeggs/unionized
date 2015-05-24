Promise = require 'bluebird'

module.exports = class Definition
  isDefinition: -> true

  constructor: (@args...) -> @initialize?()

  buildInstance: -> throw new Error("Subclasses must implement `buildInstance`!")

  buildInstanceAsync: (options) -> new Promise (resolve) => resolve(@buildInstance(options))
