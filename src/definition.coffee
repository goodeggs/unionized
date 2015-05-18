Promise = require 'bluebird'

module.exports = class Definition
  isDefinition: -> true

  constructor: (@args...) -> @initialize?()

  buildInstance: -> throw new Error("Subclasses must implement `buildInstance`!")

  buildInstanceAsync: (args...) -> new Promise (resolve) => resolve(@buildInstance(args...))
