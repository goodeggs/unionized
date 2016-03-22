_ = require 'lodash'
faker = require 'faker'
randomstring = require 'randomstring'
definitionFactory = require './definition_factory'
validator = require 'goodeggs-json-schema-validator'
objectId = require 'objectid'
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
      result = validator.validateResult(cleanedDoc, JSONSchema, null, banUnknownProperties)
      if not result.valid
        message = "Factory creation failed: #{result.error.message}"
        message += " at #{result.error.dataPath}" if result.error.dataPath?.length
        throw new Error message
      cleanedDoc

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

    when config.default
      config.default

    when config.enum?.length > 0
      -> faker.random.arrayElement config.enum

    when type is 'boolean'
      -> faker.random.arrayElement [true, false]

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
              # because faker can't generate random strings!
              return randomstring.generate(stringLength)
            else
              return faker.lorem.words()

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
        min = config.minimum ? 0
        min += 1 if config.exclusiveMinimum
        max = config.maximum ? 100
        Math.floor(Math.random() * (max - min) + min)

    when type is 'number'
      ->
        min = config.minimum ? 0
        min += 0.1 if config.exclusiveMinimum
        max = config.maximum ? 100.0
        SIG_DIGITS = 2
        magnitude = Math.pow 10, SIG_DIGITS
        min *= magnitude
        max *= magnitude
        Math.floor(Math.random() * (max - min) + min) / magnitude
