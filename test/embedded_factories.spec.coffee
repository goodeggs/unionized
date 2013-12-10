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
