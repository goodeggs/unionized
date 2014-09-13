expect    = require('chai').expect
_         = require 'lodash'
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'embedded factories', ->
  {Model, simpleFactory, embeddedFactory} = {}

  before ->
    class Model
      constructor: (attrs) ->
        _.merge @, attrs
      save: (callback) ->
        @isSaved = true
        callback null, @
      isAModel: yes
      isSaved: false

    simpleFactory = Unionized.define Model, fibrous ->
      @set 'val1', 'hello'
      @set 'val2', 'goodbye'

    embeddedFactory = Unionized.define fibrous ->
      @sync.embed 'simple1', simpleFactory
      @sync.embed 'simple2', simpleFactory

  describe 'model instantiation', ->
    describe '.create', ->
      {result} = {}

      before fibrous ->
        result = embeddedFactory.sync.create()

      it 'returns instances of Model', ->
        expect(result.simple1.isAModel).to.be.true
        expect(result.simple2.isAModel).to.be.true

      it 'saves returned Models', ->
        expect(result.simple1.isSaved).to.be.true
        expect(result.simple2.isSaved).to.be.true

    describe '.build', ->
      {result} = {}

      before fibrous ->
        result = embeddedFactory.sync.build()

      it 'returns instances of Model', ->
        expect(result.simple1.isAModel).to.be.true
        expect(result.simple2.isAModel).to.be.true

      it 'does not save returned Models', ->
        expect(result.simple1.isSaved).to.be.false
        expect(result.simple2.isSaved).to.be.false

    describe '.json', ->
      {result} = {}

      before fibrous ->
        result = embeddedFactory.sync.json()

      it 'returns plain-object instances', ->
        expect(result.simple1.isAModel).to.be.undefined
        expect(result.simple2.isAModel).to.be.undefined

  describe 'overriding embedded factory values', ->
    it 'can override an entire embedded factory', fibrous ->
      result = embeddedFactory.sync.json 'simple1': 'overridden'
      expect(result.simple1).to.equal 'overridden'
      expect(result.simple2).to.deep.equal val1: 'hello', val2: 'goodbye'

    it 'can override parts of an embedded factory', fibrous ->
      result = embeddedFactory.sync.json 'simple1.val1': 'greetings'
      expect(result.simple1).to.deep.equal val1: 'greetings', val2: 'goodbye'
