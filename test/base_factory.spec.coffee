expect    = require('chai').expect
Unionized = require '..'

describe 'using the base factory', ->

  it 'creates an empty object', ->
    result = Unionized.create()
    expect(result).to.be.defined

  it 'creates an object that contains things', ->
    result = Unionized.build
      fish: ['one', 'two', 'red', 'blue']
      'info.author': 'Theodore Geisel'

    expect(result.info.author).to.equal 'Theodore Geisel'
    expect(result.fish).to.have.length.of 4
