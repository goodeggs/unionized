expect    = require('chai').expect
_         = require 'lodash'
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'nested factories', ->
  {Model, simpleFactory, nestedFactory} = {}

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
      @val1 ?= 'hello'
      @val2 ?= 'goodbye'

    nestedFactory = Unionized.define fibrous (mode) ->
      @simple1 = simpleFactory.sync[mode]()
      @simple2 = simpleFactory.sync[mode]()

  describe '.create', ->
    {result} = {}

    before fibrous ->
      result = nestedFactory.sync.create()

    it 'returns instances of Model', ->
      expect(result.simple1.isAModel).to.be.true
      expect(result.simple2.isAModel).to.be.true

    it 'saves returned Models', ->
      expect(result.simple1.isSaved).to.be.true
      expect(result.simple2.isSaved).to.be.true

  describe '.build', ->
    {result} = {}

    before fibrous ->
      result = nestedFactory.sync.build()

    it 'returns instances of Model', ->
      expect(result.simple1.isAModel).to.be.true
      expect(result.simple2.isAModel).to.be.true

    it 'does not save returned Models', ->
      expect(result.simple1.isSaved).to.be.false
      expect(result.simple2.isSaved).to.be.false

  describe '.json', ->
    {result} = {}

    before fibrous ->
      result = nestedFactory.sync.json()

    it 'returns plain-object instances', ->
      expect(result.simple1.isAModel).to.be.undefined
      expect(result.simple2.isAModel).to.be.undefined
