expect    = require('chai').expect
_         = require 'lodash'
fibrous   = require 'fibrous'
Sweatshop = require '..'

describe 'a sweatshop with a prototype', ->
  {Model, factory} = {}

  beforeEach ->
    class Model
      constructor: (attrs) ->
        _.merge @, attrs
      save: (callback) ->
        @isSaved = true
        callback null, @
      isAModel: yes
      isSaved: false

    factory = Sweatshop.define Model, fibrous ->
      @foo ?= 10
      @biz ?= fizz: 10

  describe '.create', ->
    {result} = {}

    beforeEach fibrous ->
      result = factory.sync.create()

    it 'returns an instance of Model', ->
      expect(result.isAModel).to.be.true

    it 'calls .save() on the instance', ->
      expect(result.isSaved).to.be.true

    it 'sets all the default properties', ->
      expect(result.foo).to.equal 10
      expect(result.biz).to.deep.equal fizz: 10

  describe '.build', ->
    {result} = {}

    beforeEach fibrous ->
      result = factory.sync.build()

    it 'returns an instance of Model', ->
      expect(result.isAModel).to.be.true

    it 'returns a Model that has not been saved', ->
      expect(result.isSaved).to.be.false

    it 'sets all the default properties', ->
      expect(result.foo).to.equal 10
      expect(result.biz).to.deep.equal fizz: 10

  describe '.json', ->
    {result} = {}

    beforeEach fibrous ->
      result = factory.sync.json()

    it 'returns a plain object', ->
      expect(result.isAModel).to.be.undefined

    it 'sets all the default properties', ->
      expect(result.foo).to.equal 10
      expect(result.biz).to.deep.equal fizz: 10
