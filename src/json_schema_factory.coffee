_ = require 'lodash'
faker = require 'faker'
definitionFactory = require './definition_factory'
Factory = require './factory'
DotNotationObjectDefinition = require './dot_notation_object_definition'
EmbeddedArrayDefinition = require './embedded_array_definition'

module.exports = class JSONSchemaFactory extends Factory
  class: JSONSchemaFactory

  @fromJSONSchema: (JSONSchema) ->
    definitionObject = buildDefinitionObjectFromJSONSchemaObject(JSONSchema)
    definition = new DotNotationObjectDefinition(definitionObject)
    factory = new JSONSchemaFactory([definition])

buildDefinitionFromConfig = (config, propertyIsRequired) ->

  return switch
    when config.type is 'object'
      buildDefinitionObjectFromJSONSchemaObject(config)

    when config.type is 'array'
      arrayInstanceDefinition = buildDefinitionFromConfig(config.items, false)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

    when not propertyIsRequired
      null

    when config.default
      config.default

    when config.enum?.length > 0
      -> faker.random.array_element config.enum

    when config.type is 'boolean'
      -> faker.random.array_element [true, false]

    when config.format is 'date-time'
      -> faker.date.between(new Date('2013-01-01'), new Date('2014-01-01'))

    when config.type is 'string'
      -> faker.lorem.words().join ' '

    when config.type is 'integer'
      -> faker.random.number 100

    when config.type is 'number'
      -> faker.random.number 100

buildDefinitionObjectFromJSONSchemaObject = (JSONSchema) ->
  definitionObject = {}
  for propertyName, config of JSONSchema.properties
    isRequired = JSONSchema.required && propertyName in JSONSchema.required
    definition = buildDefinitionFromConfig(config, isRequired)
    definitionObject[propertyName] = definition if definition?
  definitionObject
