expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'inherited factories', ->
  {parent, child, result} = {}

  beforeEach fibrous ->
    parent = Unionized.define fibrous ->
      @foo ?= 'herp'
      @bar ?= 'derp'

    child = parent.define fibrous ->
      @bar ?= 'slurp'

    result = child.sync.create()

  it 'borrows default attributes up the inheritance chain', ->
    expect(result.foo).to.equal 'herp'

  it 'can overwrite default attributes', ->
    expect(result.bar).to.equal 'slurp'
