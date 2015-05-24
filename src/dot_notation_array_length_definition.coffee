Definition = require './definition'

module.exports = class DotNotationArrayLengthDefinition extends Definition
  initialize: -> [@length] = @args
  buildInstance: ({instance}) ->
    instance.length = @length
    instance

