DotNotationObjectDefinition = require './dot_notation_object_definition'
MongooseDocumentInstance = require './mongoose_document_instance'

module.exports = class MongooseDocumentDefinition extends DotNotationObjectDefinition
  initialize: ->
    @Model = @args[1]
    super()

  buildInstance: -> super(new MongooseDocumentInstance(@Model))

  buildInstanceAsync: -> super(new MongooseDocumentInstance(@Model))

