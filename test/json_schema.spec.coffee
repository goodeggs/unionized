expect = require('chai').expect
fake = require('fake-eggs').default
moment = require 'moment'
validator = require 'goodeggs-json-schema-validator'

unionized = require '../src'

describe 'JSONSchema kitten tests', ->
  beforeEach 'clear instance', ->
    @instance = null

  describe 'an instance generated by the factory with no inputs', ->
    before 'create kitten', ->
      @kittenSchema = {
        title: "Example Test Schema"
        type: "object"
        required: ["_id", "name", "tag", "bornAt", "bornDay", "contact", "website", "formattedPrice", "cutenessPercentile", "personality", "eyeColor", "isHunter"]
        properties: {
          _id: { type: "string", format: "objectid" }
          tag: { type: "string", minLength: 5, maxLength: 5 },
          name: { type: "string" },
          bornAt: { type: "string", format: "date-time" },
          bornDay: { type: "string", format: "date" },
          contact: { type: "string", format: "email" },
          website: { type: "string", format: "uri" },
          formattedPrice: { type: "string", format: "decimal" },
          cutenessPercentile: { type: "integer" },
          personality: { type: "string", enum: ["friendly", "fierce", "antisocial", "changeable"] },
          eyeColor: { type: "string", default: "yellow" },
          isHunter: { type: "boolean" },
          description: {type: "string"}
        }
      }

      @factory = unionized.JSONSchemaFactory @kittenSchema

    beforeEach 'create instance', ->
      @instance = @factory.create()

    it 'validates', ->
      expect(validator.validate(@instance, @kittenSchema)).to.be.ok

    it 'can generate a string', ->
      expect(@instance.name).to.be.a 'string'

    it 'can generate a string with a specific length', ->
      expect(@instance.tag).to.be.a 'string'
      expect(@instance.tag).to.have.length 5

    it 'can generate a string with format objectId', ->
      expect(@instance._id).to.match /^(?=[a-f\d]{24}$)(\d+[a-f]|[a-f]+\d)/i

    it 'can generate a string with format date-time', ->
      expect(moment(@instance.bornAt, moment.ISO_8601).isValid()).to.be.true

    it 'can generate a string with format date', ->
      expect(moment(@instance.bornDay, ['YYYY-MM-DD', 'YYYYYY-MM-DD']).isValid()).to.be.true

    it 'can generate string with format email', ->
      expect(@instance.contact).to.contain '@'

    it 'can generate string with format url', ->
      expect(@instance.website).to.contain 'http'

    it 'can generate string with format "decimal"', ->
      expect(@instance.formattedPrice).to.be.a('string')
      expect(
        Number.isNaN(Number(@instance.formattedPrice))
      ).to.be.false

    it 'can generate a number', ->
      expect(@instance.cutenessPercentile).to.be.a 'number'

    it 'can generate within an enum', ->
      expect(@instance.personality in ['friendly', 'fierce', 'antisocial', 'changeable']).to.be.ok

    it 'can generate a boolean', ->
      expect(@instance.isHunter).to.be.a 'boolean'

    it 'will use provided defaults', ->
      expect(@instance.eyeColor).to.equal 'yellow'

    it 'will ignore non-required attributes', ->
      expect(@instance.description).to.be.undefined

  describe 'default values', ->
    before 'create factory', ->
      @schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["shelfLife"]
        properties: {
          shelfLife: {
            type: "number"
            default: 0
          }
        }
      }
      @factory = unionized.JSONSchemaFactory @schema

    beforeEach 'create instance', ->
      @instance = @factory.create()

    it 'validates', ->
      expect(validator.validate(@instance, @schema)).to.be.ok

    it 'defaults to 0', ->
      expect(@instance.shelfLife).to.equal 0

  describe 'integers', ->
    it 'respects exclusiveMinimum', ->
      schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["frequency"]
        properties: {
          frequency: {
            type: "integer"
            minimum: 0
            exclusiveMinimum: true
            maximum: 5
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        expect(instance.frequency).not.to.equal(0)

    it 'handles special case of single possible integer due to exclusiveMinimum', ->
      schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["frequency"]
        properties: {
          frequency: {
            type: "integer"
            minimum: 4
            exclusiveMinimum: true
            maximum: 5
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        # can only ever be 5
        expect(instance.frequency).to.equal(5)

    it 'respects exclusiveMaximum', ->
      schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["frequency"]
        properties: {
          frequency: {
            type: "integer"
            minimum: 0
            maximum: 5
            exclusiveMaximum: true
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        expect(instance.frequency).not.to.equal(5)

    it 'handles special case of single possible integer due to exclusiveMaximum', ->
      schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["frequency"]
        properties: {
          frequency: {
            type: "integer"
            minimum: 4
            maximum: 5
            exclusiveMaximum: true
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        # can only ever be 4
        expect(instance.frequency).to.equal(4)

  describe 'numbers', ->
    it 'respects exclusiveMinimum', ->
      schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["frequency"]
        properties: {
          frequency: {
            type: "number"
            minimum: 0
            exclusiveMinimum: true
            maximum: 1
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        expect(instance.frequency).not.to.equal(0)

    it 'respects exclusiveMaximum', ->
      schema = {
        title: "Example Test Schema"
        type: "object"
        required: ["frequency"]
        properties: {
          frequency: {
            type: "number"
            minimum: 0
            maximum: 1
            exclusiveMaximum: true
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        expect(instance.frequency).not.to.equal(1)

  describe 'string format "decimal"', ->
    # Just test `minimum` to verify that we are correctly deferring to underlying `number` logic.
    it 'respects `maximum`', ->
      schema = {
        type: "object"
        required: ["formattedPrice"]
        properties: {
          formattedPrice: {
            type: "string"
            format: "decimal"
            maximum: 5
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)
      for time in [0...100]
        instance = factory.create()
        expect(instance.formattedPrice).to.be.a('string')
        price = Number(instance.formattedPrice)
        expect(Number.isNaN(price)).to.be.false
        expect(price).to.be.lessThan(5)

  describe 'instantiating with unknown field', ->
    before 'create kitten', ->
      @kittenSchema = {
        "type": "object",
        "properties": {
          "name": { "type": "string" }
        },
        "required": ["name"]
      }

      @factory = unionized.JSONSchemaFactory @kittenSchema

    it 'validates', ->
      expect(=> @factory.create({age: 15})).to.throw 'Factory creation failed; failed schema validation for data path /age; unknown property (not in schema)'

  describe 'allowing unknown properties', ->
    before 'create kitten', ->
      @kittenSchema = {
        "type": "object",
        "properties": {
          "name": { "type": "string" }
        },
        "required": ["name"]
      }

      @factory = unionized.JSONSchemaFactory(@kittenSchema, {banUnknownProperties: false})

    it 'does not error when using unknown property', ->
      expect(=> @factory.create({age: 15})).not.to.throw()

  describe 'arrays', ->
    before 'create kitten', ->
      kitten2 =
        title: "Kitten2"
        type: "object"
        required: ['paws']
        properties:
          siblings:
            type: 'array'
            items:
              type: 'string'
          paws:
            type: "array"
            items:
              type: "object"
              required: ["nickname"]
              properties:
                nickname: {type: "string"}
                clawCount: {type: "number"}

      @factory = unionized.JSONSchemaFactory kitten2

    beforeEach 'create kitten', ->
      @instance = @factory.create()

    it 'can generate an array', ->
      expect(@instance.paws).to.be.an.instanceOf Array

    it 'does not generate array if not required', ->
      expect(@instance.siblings).to.equal undefined

    it 'generates required properties on array elements', ->
      expect(@instance.paws[0]).to.be.a 'object'
      expect(@instance.paws[0]).to.have.property 'nickname'
      expect(@instance.paws[0].clawCount).not.to.be.ok

    it 'generates a number of array elements greater than or equal to given `minItems` if provided', ->
      minItems = fake.integer(0, 100)
      schema = {
        # TODO(serhalp) unionized does not support top-level arrays - simplify this when it does
        type: 'object',
        required: ['arr'],
        properties: {
          arr: {
            type: 'array'
            items: {
              type: 'integer'
            }
            minItems
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)

      expect(factory.create().arr).to.have.length.of.at.least(minItems)

    it 'generates a number of array elements less than or equal to given `maxItems` if provided', ->
      maxItems = fake.integer(0, 100)
      schema = {
        # TODO(serhalp) unionized does not support top-level arrays - simplify this when it does
        type: 'object',
        required: ['arr'],
        properties: {
          arr: {
            type: 'array'
            items: {
              type: 'integer'
            }
            maxItems
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)

      expect(factory.create().arr).to.have.length.at.most(maxItems)

    it 'generates a number of array elements between `minItems` and `maxItems` inclusively if provided', ->
      minItems = fake.integer(0, 100)
      maxItems = fake.integer(minItems, 200)
      schema = {
        # TODO(serhalp) unionized does not support top-level arrays - simplify this when it does
        type: 'object',
        required: ['arr'],
        properties: {
          arr: {
            type: 'array'
            items: {
              type: 'integer'
            }
            minItems
            maxItems
          }
        }
      }
      factory = unionized.JSONSchemaFactory(schema)

      expect(factory.create().arr).to.have.length.within(minItems, maxItems)

  describe 'deeply-nested attributes', ->
    before 'create kitten', ->
      kitten3 = {
        "title": "Kitten2",
        "type": "object",
        "required": ['meta']
        "properties": {
          "meta": {
            "type": "object",
            "required": ["owner"]
            "properties": {
              "owner": {
                "type": "object"
                "properties": {
                  "name": {"type": "string"}
                  "age": {"type": "number"}
                }
                "required": ["name"]
              }
            }
          }
        }
      }

      @factory = unionized.JSONSchemaFactory kitten3

    beforeEach 'create instance', ->
      @instance = @factory.create()

    it 'are generated', ->
      expect(@instance?.meta?.owner?.name).to.have.length.of.at.least 1
      expect(@instance?.meta?.owner?.age).not.to.be.ok

  describe 'an instance generated with inputs', ->
    before 'create kitten', ->
      kitten4 = {
        "title": "Kitten2",
        "type": "object",
        "properties": {
          "name": {"type": "string"}
          "age": {"type": "number"}
          "meta": {
            type: "object",
            "properties": {
              "owner": {
                type: "object",
                "properties": {
                  "name": {"type": "string"}
                  "age": {"type": "integer"}
                }
              }
            }
          }
        },
        "required": ["name"]
      }

      @factory = unionized.JSONSchemaFactory kitten4

    beforeEach 'create instance', ->
      @instance = @factory.create {
        name: 'John Doe'
        meta:
          owner:
            age: 30
        'meta.owner.name': 'Joe Shmoe'
      }

    it 'respects top-level inputs', ->
      expect(@instance).to.have.property 'name', 'John Doe'

    it 'respects deeply-nested object inputs', ->
      expect(@instance?.meta?.owner?.age).to.equal 30

    it 'respects deeply-nested dot-pathed arguments', ->
      expect(@instance?.meta?.owner?.name).to.equal 'Joe Shmoe'

  describe 'extending factories', ->
    before 'create kitten', ->
      kitten5 = {
        "title": "Kitten2",
        "type": "object",
        "properties": {
          "name": {"type": "string"}
          "age": {"type": "number"}
          "description": {"type": "string"}
        },
        "required": ["name", "age"]
      }

      @factory = unionized.JSONSchemaFactory(kitten5).factory name: 'Fluffy'

    beforeEach 'create instance', ->
      @instance = @factory.create { description: 'Big ball of fluff' }

    it 'combines default attributes', ->
      expect(@instance).to.have.property 'name', 'Fluffy'
      expect(@instance).to.have.property 'age'
      expect(@instance.age).to.be.a 'number'

    it 'takes inputs', ->
      expect(@instance).to.have.property 'description', 'Big ball of fluff'

  describe 'onCreate hooks', ->
    before 'create kitten', ->
      kitten6 = {
        "title": "Kitten2",
        "type": "object",
        "properties": {
          "age": {"type": "number"}
          "humanEquivalentAge": {"type": "number"}
        },
        "required": ["age"]
      }

      @factory = unionized.JSONSchemaFactory(kitten6).onCreate (instance) ->
        instance.humanEquivalentAge = instance.age * 3
        instance

    beforeEach 'create instance', ->
      @instance = @factory.create { age: 1 }

    it 'combines default attributes', ->
      expect(@instance).to.have.property 'age', 1
      expect(@instance).to.have.property 'humanEquivalentAge', 3
