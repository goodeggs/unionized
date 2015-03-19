expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a synchronous factory', ->
  {factory} = {}

  beforeEach ->
    factory = Unionized.define ->
      @set 'name', 'apple'

  it 'creates an object', fibrous ->
    result = factory.json
      'type': 'fruit'
    expect(result.name).to.equal 'apple'
    expect(result.type).to.equal 'fruit'

  it 'inherits from parents', fibrous ->
    child = factory.define ->
      @set 'store', 'Whole Foods'

    result = child.json()
    expect(result.store).to.equal 'Whole Foods'
    expect(result.name).to.equal 'apple'
