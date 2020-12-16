_ = require 'lodash'
fake = require('fake-eggs').default

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
      -> fake.sample(schemaType.enumValues)

    when schemaType instanceof mongoose.SchemaTypes.Array
      arrayInstanceDefinition = buildDefinitionFromSchemaType(schemaType.caster, mongoose, ignoreRequired: false)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when schemaType instanceof mongoose.SchemaTypes.ObjectId
      -> new mongoose.Types.ObjectId()

    when schemaType instanceof mongoose.SchemaTypes.Boolean
      -> fake.boolean()

    when schemaType instanceof mongoose.SchemaTypes.Date
      fake.date

    when schemaType instanceof mongoose.SchemaTypes.String
      fake.string

    when schemaType instanceof mongoose.SchemaTypes.Number
      ->
        min = schemaType.options.min ? -100
        max = schemaType.options.max ? 100
        # TODO(serhalp) Isn't mongoose `max` inclusive and `fake.number` max exclusive...? I guess
        # this will never generate invalid data, but it's not covering the full domain.
        return fake.number(min, max)

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
