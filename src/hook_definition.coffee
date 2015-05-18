Definition = require './definition'

module.exports = class HookDefinition extends Definition
  initialize: ->
    [@hook] = @args

  buildInstance: (instance) ->
    instance ?= new ObjectInstance()
    instance.hooks.push(@hook)
    instance
