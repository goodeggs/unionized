expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'factories with arguments', ->
  {factory} = {}

  describe 'a factory that creates an object whose values are dependent on other values', ->

    beforeEach ->
      factory = Unionized.define fibrous (foobar) ->
        @set 'foo.bar', foobar
        @set 'baz', 10

    it 'passes arguments into the factory function', fibrous ->
      result = factory.sync.json({}, 12)
      expect(result.foo.bar).to.equal 12

    it 'sets the default values properly', fibrous ->
      result = factory.sync.json({}, 12)
      expect(result.baz).to.equal 10
