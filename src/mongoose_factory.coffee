_ = require 'lodash'
faker = require 'faker'
definitionFactory = require './definition_factory'
Factory = require './factory'
MongooseDocumentDefinition = require './mongoose_document_definition'
EmbeddedArrayDefinition = require './embedded_array_definition'

buildDefinitionObjectFromSchema = (schema, mongoose) ->
  definitionObject = {}
  schema.eachPath (pathName, schemaType) ->
    switch
      when schemaType instanceof mongoose.SchemaTypes.DocumentArray
        arrayInstanceDefinition = buildDefinitionObjectFromSchema(schemaType.schema, mongoose)
        definitionObject[pathName] = -> new EmbeddedArrayDefinition arrayInstanceDefinition

      when pathName is '_id'
        definitionObject[pathName] = -> new mongoose.Types.ObjectId()

      when not schemaType.isRequired then return

      when schemaType.defaultValue? and typeof schemaType.defaultValue isnt 'function'
        definitionObject[pathName] = schemaType.defaultValue

      when schemaType.enumValues?.length > 0
        definitionObject[pathName] = -> faker.random.array_element schemaType.enumValues

      when schemaType instanceof mongoose.SchemaTypes.ObjectId
        definitionObject[pathName] = -> new mongoose.Types.ObjectId()

      when schemaType instanceof mongoose.SchemaTypes.Boolean
        definitionObject[pathName] = -> faker.random.array_element [true, false]

      when schemaType instanceof mongoose.SchemaTypes.Date
        definitionObject[pathName] = -> faker.date.between(new Date('2013-01-01'), new Date('2014-01-01'))

      when schemaType instanceof mongoose.SchemaTypes.String
        definitionObject[pathName] = -> faker.lorem.words().join ' '

      when schemaType instanceof mongoose.SchemaTypes.Number
        definitionObject[pathName] = -> faker.random.number 100

  definitionObject

module.exports = class MongooseFactory extends Factory
  factory: (definition) ->
    new MongooseFactory [@definitions..., definitionFactory(definition)]

  createAndSave: (args...) ->
    optionalDefinition = args[0] if _.isObject(args[0]) and not _.isFunction(args[0])
    callback = args[args.length - 1] if _.isFunction(args[args.length - 1])
    return @factory(optionalDefinition).createAndSave(callback) if optionalDefinition?
    @stageAsync().then((instance) -> instance.toObjectAsync(save: true)).asCallback(callback)

  createLeanAsync: (args...) ->
    optionalDefinition = args[0] if _.isObject(args[0]) and not _.isFunction(args[0])
    callback = args[args.length - 1] if _.isFunction(args[args.length - 1])
    return @factory(optionalDefinition).createLeanAsync(callback) if optionalDefinition?
    @stageAsync().then((instance) -> instance.toObjectAsync(lean: true)).asCallback(callback)

  @createFromModel: (Model) ->
    mongoose = Model.db.base
    definitionObject = buildDefinitionObjectFromSchema(Model.schema, mongoose)
    new MongooseFactory [new MongooseDocumentDefinition(definitionObject, Model)]
