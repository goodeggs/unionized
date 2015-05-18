Definition = require './definition'

module.exports = class HookDefinition extends Definition
  initialize: ->
    [@hook] = @args
  stage: (instance) ->
    instance ?= new ObjectInstance()
    instance.hooks.push(@hook)
    instance
