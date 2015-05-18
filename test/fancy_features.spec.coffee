expect = require('chai').expect
unionized = require '..'

describe 'fancy features', ->
  it 'will pick an item from an array with enum', ->
    randomItem = unionized.enum(['foo', 'bar', 'baz'])
    expect(randomItem() in ['foo', 'bar', 'baz']).to.be.true
