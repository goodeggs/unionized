_ = require 'lodash'
fake = require 'fake-eggs'
definitionFactory = require './definition_factory'
validator = require 'goodeggs-json-schema-validator'
Factory = require './factory'
DotNotationObjectDefinition = require './dot_notation_object_definition'
EmbeddedArrayDefinition = require './embedded_array_definition'

module.exports = class JSONSchemaFactory extends Factory
  class: JSONSchemaFactory

  @fromJSONSchema: (JSONSchema, {banUnknownProperties} = {}) ->
    # Ban unknown properties by default.
    # We always want to be explicit about data setup in tests
    banUnknownProperties ?= true
    definitionObject = buildDefinitionFromJSONSchema(JSONSchema, true)
    definition = new DotNotationObjectDefinition(definitionObject)
    factory = new JSONSchemaFactory([definition])
    factory.onCreate (doc) ->
      cleanedDoc = JSON.parse JSON.stringify doc # remove undefined, convert dates to ISO strings, etc
      validator.assertValid(cleanedDoc, JSONSchema, 'Factory creation failed', {banUnknownProperties})
      return cleanedDoc

buildDefinitionFromJSONSchema = (config, propertyIsRequired) ->
  type = if Array.isArray config.type then config.type[0] else config.type

  switch
    when not propertyIsRequired
      undefined

    when type is 'object'
      definitionObject = {}
      for propertyName, propertyConfig of config.properties
        isRequired = config.required && propertyName in config.required
        definition = buildDefinitionFromJSONSchema(propertyConfig, isRequired)
        definitionObject[propertyName] = definition if definition?
      definitionObject

    when type is 'array'
      arrayInstanceDefinition = buildDefinitionFromJSONSchema(config.items, true)
      -> new EmbeddedArrayDefinition arrayInstanceDefinition, generateArrayLength(config)

    when config.default?
      config.default

    when config.enum?.length > 0
      -> _.sample(config.enum)

    when type is 'boolean'
      -> _.sample([true, false])

    when type is 'string'
      switch config.format
        when undefined
          ->
            stringLength = do ->
              return unless config.minLength or config.maxLength
              minLength = config.minLength or 0
              maxLength = config.maxLength or minLength
              lengthDifference = maxLength - minLength
              Math.floor(Math.random() * lengthDifference) + minLength
            if stringLength
              return fake.string(stringLength)
            else
              return fake.string()

        # see https://github.com/goodeggs/goodeggs-json-schema-validator for supported formats
        when 'objectid'
          fake.objectId

        when 'date-time'
          fake.date

        when 'date'
          -> fake.date().toISOString().slice(0,10)

        when 'email'
          fake.email

        when 'uri'
          fake.uri

    when type is 'integer'
      ->
        min = config.minimum ? -100
        min += 1 if config.exclusiveMinimum
        max = config.maximum ? 100
        max -= 1 if config.exclusiveMaximum
        fake.integer(min, max)

    when type is 'number'
      ->
        min = config.minimum ? -100
        min += 0.001 if config.exclusiveMinimum
        max = config.maximum ? 100
        max -= 0.001 if config.exclusiveMaximum
        fake.number(min, max)

generateArrayLength = (config) ->
  # Ensure we generate valid defaults in all cases:
  # - no minItems, no maxItems: 0 to 100
  # - minItems only: minItems to (minItems+100)
  # - maxItems only: 0 to maxItems
  # - minItems, maxItems: use them
  minItems = config.minItems ? 0
  maxItems = config.maxItems ? minItems + 100
  return Math.floor(Math.random() * (maxItems - minItems)) + minItems
