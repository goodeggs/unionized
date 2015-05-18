DotNotationObjectDefinition = require './dot_notation_object_definition'
MongooseDocumentInstance = require './mongoose_document_instance'

module.exports = class MongooseDocumentDefinition extends DotNotationObjectDefinition
  initialize: ->
    @Model = @args[1]
    super()
  stage: -> super(new MongooseDocumentInstance(@Model))
  stageAsync: -> super(new MongooseDocumentInstance(@Model))

