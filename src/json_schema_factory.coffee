_ = require 'lodash'
fake = require('fake-eggs').default
validator = require 'goodeggs-json-schema-validator'

definitionFactory = require './definition_factory'
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
          # Don't bother generating Expanded Years (https://tc39.es/ecma262/#sec-expanded-years)
          # even though it's part of the ISO 8601 spec. It just isn't worth it. Sorry for
          # contributing to Y10K.
          -> fake.day('1001-01-01', '9999-01-01')

        when 'email'
          fake.email

        when 'uri'
          fake.uri

    when type is 'integer'
      ->
        minInclusive = config.minimum ? -100
        minInclusive += 1 if (config.exclusiveMinimum ? false)
        maxExclusive = config.maximum ? 100
        maxExclusive += 1 if not (config.exclusiveMaximum ? false)
        return fake.integer(minInclusive, maxExclusive)

    when type is 'number'
      ->
        minInclusive = config.minimum ? -100
        # This is a bit brittle, but the number of decimal places here must be the same as in
        # fake-eggs here:
        # https://github.com/goodeggs/fake-eggs/blob/2d4f6098be8fd104cfe10451ab805f886e02e5a4/src/generators/number/index.ts#L12-L13.
        # This is because we're taking a possibly inclusive or exclusive float, passing it to a
        # function that takes an always exclusive float, which then passes it to a function
        # internally that takes an inclusive float. The delta applied to toggle exclusive/inclusive
        # must be the same at every level.
        minInclusive += 0.0001 if (config.exclusiveMinimum ? false)
        maxExclusive = config.maximum ? 100
        maxExclusive += 0.0001 if not (config.exclusiveMaximum ? false)
        return fake.number(minInclusive, maxExclusive)

generateArrayLength = (config) ->
  # Ensure we generate valid defaults in all cases:
  # - no minItems, no maxItems: 0 to 100
  # - minItems only: minItems to (minItems+100)
  # - maxItems only: 0 to maxItems
  # - minItems, maxItems: use them
  minItems = config.minItems ? 0
  maxItems = config.maxItems ? minItems + 100
  return Math.floor(Math.random() * (maxItems - minItems)) + minItems
