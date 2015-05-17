Definition = require './definition'

module.exports = class DotNotationArrayLengthDefinition extends Definition
  initialize: -> [@length] = @args
  stage: (instance) ->
    instance.length = @length
    instance

