expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a factory that unsets values', ->
  {factory} = {}

  beforeEach ->
    factory = Unionized.define fibrous ->
      @set 'foo', 10
      @unset 'bar'

  it 'does not have bar set by default', fibrous ->
    result = factory.sync.create()
    expect(result.bar).not.to.be.defined

  it 'unsets bar if bar does get set', fibrous ->
    result = factory.sync.create bar: 'baz'
    expect(result.bar).not.to.be.defined
