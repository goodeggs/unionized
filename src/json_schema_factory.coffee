_ = require 'lodash'
faker = require 'faker'
definitionFactory = require './definition_factory'
validator = require 'goodeggs-json-schema-validator'
objectId = require 'objectid'
Factory = require './factory'
DotNotationObjectDefinition = require './dot_notation_object_definition'
EmbeddedArrayDefinition = require './embedded_array_definition'

module.exports = class JSONSchemaFactory extends Factory
  class: JSONSchemaFactory

  @fromJSONSchema: (JSONSchema) ->
    definitionObject = buildDefinitionFromJSONSchema(JSONSchema, true)
    definition = new DotNotationObjectDefinition(definitionObject)
    factory = new JSONSchemaFactory([definition])
    factory.onCreate (doc) ->
      cleanedDoc = JSON.parse JSON.stringify doc # remove undefined, convert dates to ISO strings, etc
      # Ban unkown properties. We always want to be explicit about data setup in tests
      if not validator.validate(cleanedDoc, JSONSchema, null, true)
        message = "Factory creation failed: #{validator.error.message}"
        message += " at #{validator.error.dataPath}" if validator.error.dataPath?.length
        throw new Error message
      cleanedDoc

buildDefinitionFromJSONSchema = (config, propertyIsRequired) ->
  type = if Array.isArray config.type then config.type[0] else config.type

  switch
    when type is 'object'
      buildDefinitionObjectFromJSONSchemaObject(config)

    when type is 'array'
      arrayInstanceDefinition = buildDefinitionFromJSONSchema(config.items, false)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when not propertyIsRequired
      null

    when config.default
      config.default

    when config.enum?.length > 0
      -> faker.random.array_element config.enum

    when type is 'boolean'
      -> faker.random.array_element [true, false]

    when type is 'string'
      switch config.format
        when undefined
          -> faker.lorem.words().join ' '

        # see https://github.com/goodeggs/goodeggs-json-schema-validator for supported formats
        when 'objectid'
          -> objectId() # works in both server and client

        when 'date-time'
          -> faker.date.between(new Date('2013-01-01'), new Date('2014-01-01')).toISOString()

        when 'date'
          -> faker.date.between(new Date('2013-01-01'), new Date('2014-01-01')).toISOString().slice(0,10)

        when 'email'
          -> faker.internet.email()

        when 'uri'
          -> faker.internet.url()

    when type is 'integer'
      ->
        faker.random.number({
          min: config.minimum or 0
          max: config.maximum or 100
        })

    when type is 'number'
      ->
        faker.random.number({
          min: config.minimum or 0
          max: config.maximum or 100
        })

buildDefinitionObjectFromJSONSchemaObject = (JSONSchema) ->
  definitionObject = {}
  for propertyName, config of JSONSchema.properties
    isRequired = JSONSchema.required && propertyName in JSONSchema.required
    definition = buildDefinitionFromJSONSchema(config, isRequired)
    definitionObject[propertyName] = definition if definition?
  definitionObject
