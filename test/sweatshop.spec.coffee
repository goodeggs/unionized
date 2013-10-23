_         = require 'lodash'
chai      = require 'chai'
fibrous   = require 'fibrous'
Sweatshop = require '../sweatshop.js'

expect = chai.expect

class Model
  constructor: (attrs) ->
    @saved = false
    _.merge @, attrs
  save: (callback) ->
    @saved = true
    callback null, @

describe 'sweatshop', ->
  {plainFactory, modelFactory, parentModelFactory} = {}
  beforeEach ->
    plainFactory = Sweatshop.define (callback) ->
      @foo ?= 10
      @biz ?= fizz: 10
      callback()

    modelFactory = Sweatshop.define Model, fibrous ->
      @plain ?= plainFactory.sync.create()

    parentModelFactory = Sweatshop.define Model, fibrous ->
      @model = modelFactory.sync.create @model unless @model instanceof Model

  describe 'anonymous factories', ->
    describe 'for plain objects', ->
      it 'creates an object', fibrous ->
        result = plainFactory.sync.create()
        expect(result).to.be.eql foo: 10, biz: fizz: 10

      it 'adds a new property', fibrous ->
        result = plainFactory.sync.create {baz: 20}
        expect(result).to.be.eql foo: 10, baz: 20, biz: fizz: 10

      it 'changes property', fibrous ->
        result = plainFactory.sync.create {foo: 20}
        expect(result).to.be.eql foo: 20, biz: fizz: 10

      it 'changes property', fibrous ->
        result = plainFactory.sync.create {biz: fizz: 20}
        expect(result).to.be.eql foo: 10, biz: fizz: 20

    describe 'for a model', ->
      it 'creates a model instance', fibrous ->
        result = modelFactory.sync.create()
        expect(result).to.be.instanceof Model
        expect(result).to.be.eql new Model saved: true, plain: foo: 10, biz: fizz: 10

      it 'adds a new property', fibrous ->
        result = modelFactory.sync.create {foo: 20}
        expect(result).to.be.eql new Model saved: true, plain: {foo: 10, biz: fizz: 10}, foo: 20

      it 'uses passed plain object', fibrous ->
        result = modelFactory.sync.create {plain: foo: 20}
        expect(result).to.be.eql new Model saved: true, plain: foo: 20

      it 'does not save if we just build', fibrous ->
        result = modelFactory.sync.build()
        expect(result.saved).to.not.be.true

      it 'does not create a model instance if we just call json', fibrous ->
        result = modelFactory.sync.json()
        expect(result).not.to.be.instanceof Model

    describe 'for a nested model', ->
      it 'created nested model', fibrous ->
        result = parentModelFactory.sync.create()
        expect(result).to.be.eql new Model saved: true, model: new Model {saved: true, plain: foo: 10, biz: fizz: 10}

      it 'changes nested model property', fibrous ->
        result = parentModelFactory.sync.create {model: plain: foo: 20}
        expect(result).to.be.eql new Model saved: true, model: new Model {saved: true, plain: foo: 20}

  describe 'global factories', ->
    describe 'for unknown factory', ->
      it 'throws an error', ->
        expect(-> Sweatshop.sync.create 'unknown').to.throw 'Unknown factory `unknown`'

    describe 'for a known factory', ->
      it 'creates and uses a factory', fibrous ->
        Sweatshop.define 'known', (callback) ->
          @fiz = 'buzz'
          callback()
        {fiz} = Sweatshop.sync.create('known')
        expect(fiz).to.equal 'buzz'
