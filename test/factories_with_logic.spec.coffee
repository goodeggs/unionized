expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'factories with logic', ->
  {factory} = {}

  describe 'a factory that creates an object whose values are dependent on other values', ->

    beforeEach ->
      factory = Unionized.define fibrous ->
        @set 'smaller', 10
        @set 'larger', @get('smaller') + 10

    it 'sets the default values properly', fibrous ->
      result = factory.sync.json()
      expect(result.smaller).to.equal 10
      expect(result.larger).to.equal 20

    it 'sets the dependent value based on input', fibrous ->
      result = factory.sync.json smaller: 20
      expect(result.smaller).to.equal 20
      expect(result.larger).to.equal 30
