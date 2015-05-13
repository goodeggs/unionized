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
        expect(-> factory.json(->)).to.throw()

    describe 'with arguments', ->
      it 'creates an object', ->
        result = factory.json
          'type': 'fruit'
        expect(result.name).to.equal 'apple'
        expect(result.type).to.equal 'fruit'

      it 'does not accept a callback', ->
        expect(-> factory.json({type: 'fruit'}, (->))).to.throw()

  describe '.build', ->
    # (the same as `json` in this case, b/c there's no model)
    describe 'with no arguments', ->
      it 'creates an object', ->
        result = factory.build()
        expect(result.name).to.equal 'apple'

      it 'does not accept a callback', ->
        expect(-> factory.build(->)).to.throw()

    describe 'with arguments', ->
      it 'creates an object', ->
        result = factory.build
          'type': 'fruit'
        expect(result.name).to.equal 'apple'
        expect(result.type).to.equal 'fruit'

      it 'does not accept a callback', ->
        expect(-> factory.build({type: 'fruit'}, (->))).to.throw()


  describe '.create', ->
    it 'is not allowed', ->
      expect(-> factory.create()).to.throw()

