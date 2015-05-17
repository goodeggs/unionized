_ = require 'lodash'
Definition = require './definition'
definitionFactory = require './definition_factory'

module.exports = class FunctionDefinition extends Definition
  initialize: -> [@function] = @args
  stage: (args...) ->
    definitionFactory(@function(_.compact(args)...)).stage(args...)
  stageAsync: (args...) ->
    definitionFactory(@function(_.compact(args)...)).stageAsync(args...)

