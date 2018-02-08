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
      -> new EmbeddedArrayDefinition arrayInstanceDefinition

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
              return fake.randomString(stringLength)
            else
              return fake.randomString()

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
        min = config.minimum ? 0
        min += 1 if config.exclusiveMinimum
        max = config.maximum ? 100
        fake.integerInRange(min, max)

    when type is 'number'
      ->
        min = config.minimum ? 0
        max = config.maximum ? 100.0
        SIG_DIGITS = 2
        magnitude = Math.pow 10, SIG_DIGITS
        min = Math.ceil(min * magnitude)
        min = min + 1 if config.exclusiveMinimum
        max = Math.floor(max * magnitude)
        fake.integerInRange(min, max) / magnitude
