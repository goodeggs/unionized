expect    = require('chai').expect
Unionized = require '..'

describe 'using the base factory', ->

  describe '.json', ->
    it 'creates an empty object', ->
      result = Unionized.json
      expect(result).to.be.ok

    it 'creates an object that contains things', ->
      result = Unionized.json
        fish: ['one', 'two', 'red', 'blue']
        'info.author': 'Theodore Geisel'
      expect(result.info.author).to.equal 'Theodore Geisel'
      expect(result.fish).to.have.length.of 4

  describe '.build and .create', ->
    it 'are not supported (b/c it\'s synchronous)', ->
      expect(-> Unionized.create(->)).to.throw /create.*synchronous/i
      expect(-> Unionized.build(->)).to.throw /build.*synchronous/i