_ = require 'lodash'
expect = require('chai').expect

unionized = require '..'

describe 'fancy features', ->
  it 'will pick an item from an array with enum', ->
    randomItem = unionized.enum(['foo', 'bar', 'baz'])
    expect(randomItem() in ['foo', 'bar', 'baz']).to.be.true

  it 'binds factory function so that it can be called from another context and still work', ->
    factory = unionized.factory({foo: 'bar'})
    expect(_.times(3, factory.create)).to.have.length 3
