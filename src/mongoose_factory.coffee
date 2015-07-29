_ = require 'lodash'
faker = require 'faker'
definitionFactory = require './definition_factory'
Factory = require './factory'
DotNotationObjectDefinition = require './dot_notation_object_definition'
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
      -> faker.random.arrayElement schemaType.enumValues

    when schemaType instanceof mongoose.SchemaTypes.Array
      arrayInstanceDefinition = buildDefinitionFromSchemaType(schemaType.caster, mongoose, ignoreRequired: false)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when schemaType instanceof mongoose.SchemaTypes.ObjectId
      -> new mongoose.Types.ObjectId()

    when schemaType instanceof mongoose.SchemaTypes.Boolean
      -> faker.random.arrayElement [true, false]

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
  class: MongooseFactory

  createLean: (args) ->
    @onCreate((document) -> document.toObject())
      .create(args...)

  createLeanAsync: (args...) ->
    @onCreate((document) -> document.toObject())
      .createAsync(args...)

  createAndSave: (args...) ->
    @onCreate((document) -> document.save())
      .createAsync(args...)

  @fromModel: (Model) ->
    definitionObject = buildDefinitionObjectFromSchema(Model.schema, Model.db.base)
    definition = new DotNotationObjectDefinition(definitionObject)
    factory = new MongooseFactory([definition])
    factory.onCreate (leanDoc) -> new Model leanDoc
