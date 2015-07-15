_ = require 'lodash'
faker = require 'faker'
definitionFactory = require './definition_factory'
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

buildDefinitionFromJSONSchema = (config, propertyIsRequired) ->

  switch
    when config.type is 'object'
      buildDefinitionObjectFromJSONSchemaObject(config)

    when config.type is 'array'
      arrayInstanceDefinition = buildDefinitionFromJSONSchema(config.items, false)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when not propertyIsRequired
      null

    when config.default
      config.default

    when config.enum?.length > 0
      -> faker.random.array_element config.enum

    when config.type is 'boolean'
      -> faker.random.array_element [true, false]

    when config.type is 'string'
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

    when config.type is 'integer'
      -> faker.random.number 100

    when config.type is 'number'
      -> faker.random.number 100

buildDefinitionObjectFromJSONSchemaObject = (JSONSchema) ->
  definitionObject = {}
  for propertyName, config of JSONSchema.properties
    isRequired = JSONSchema.required && propertyName in JSONSchema.required
    definition = buildDefinitionFromJSONSchema(config, isRequired)
    definitionObject[propertyName] = definition if definition?
  definitionObject
