expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a synchronous factory', ->
  {factory} = {}

  beforeEach ->
    factory = Unionized.define ->
      @set 'name', 'apple'

  describe '.json', ->
    describe 'with no arguments', ->
      it 'creates an object', ->
        result = factory.json()
        expect(result.name).to.equal 'apple'

      it 'does not accept a callback', ->
        expect(-> factory.json(->)).to.throw /sync.*callback/i

    describe 'with arguments', ->
      it 'creates an object', ->
        result = factory.json
          'type': 'fruit'
        expect(result.name).to.equal 'apple'
        expect(result.type).to.equal 'fruit'

      it 'does not accept a callback', ->
        expect(-> factory.json({type: 'fruit'}, (->))).to.throw /sync.*callback/i

  describe '.build', ->
    it 'is not allowed', ->
      expect(-> factory.build()).to.throw /async/i

  describe '.create', ->
    it 'is not allowed', ->
      expect(-> factory.create()).to.throw /async/i

