Promise = require 'bluebird'

module.exports = class Definition
  isDefinition: -> true
  constructor: (@args...) -> @initialize?()
  stage: -> throw new Error("Subclasses must implement `stage`!")
  stageAsync: (args...) -> new Promise (resolve) => resolve(@stage(args...))
