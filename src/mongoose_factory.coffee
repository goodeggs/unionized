_ = require 'lodash'
faker = require 'faker'
definitionFactory = require './definition_factory'
Factory = require './factory'
MongooseDocumentDefinition = require './mongoose_document_definition'
EmbeddedArrayDefinition = require './embedded_array_definition'

buildDefinitionFromSchemaType = (schemaType, mongoose, {ignoreRequired} = {}) ->
  ignoreRequired ?= true

  return switch
    when schemaType instanceof mongoose.SchemaTypes.DocumentArray
      arrayInstanceDefinition = buildDefinitionObjectFromSchema(schemaType.schema, mongoose)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when ignoreRequired and not schemaType.isRequired
      null

    when schemaType.defaultValue? and typeof schemaType.defaultValue isnt 'function'
      schemaType.defaultValue

    when schemaType.enumValues?.length > 0
      -> faker.random.array_element schemaType.enumValues

    when schemaType instanceof mongoose.SchemaTypes.Array
      arrayInstanceDefinition = buildDefinitionFromSchemaType(schemaType.caster, mongoose, ignoreRequired: false)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when schemaType instanceof mongoose.SchemaTypes.ObjectId
      -> new mongoose.Types.ObjectId()

    when schemaType instanceof mongoose.SchemaTypes.Boolean
      -> faker.random.array_element [true, false]

    when schemaType instanceof mongoose.SchemaTypes.Date
      -> faker.date.between(new Date('2013-01-01'), new Date('2014-01-01'))

    when schemaType instanceof mongoose.SchemaTypes.String
      -> faker.lorem.words().join ' '

    when schemaType instanceof mongoose.SchemaTypes.Number
      -> faker.random.number 100

buildDefinitionObjectFromSchema = (schema, mongoose) ->
  definitionObject = {}
  schema.eachPath (pathName, schemaType) ->
    definition =
      if pathName is '_id'
        -> new mongoose.Types.ObjectId()
      else
        buildDefinitionFromSchemaType schemaType, mongoose
    definitionObject[pathName] = definition if definition?
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
