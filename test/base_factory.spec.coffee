expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'using the base factory', ->

  it 'creates an empty object', fibrous ->
    result = Unionized.sync.create()
    expect(result).to.be.defined

  it 'creates an object that contains things', fibrous ->
    result = Unionized.sync.create
      fish: ['one', 'two', 'red', 'blue']
      'info.author': 'Theodore Geisel'

    expect(result.info.author).to.equal 'Theodore Geisel'
    expect(result.fish).to.have.length.of 4
