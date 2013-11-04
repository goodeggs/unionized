expect    = require('chai').expect
fibrous   = require 'fibrous'
Sweatshop = require '..'

describe 'inherited sweatshops', ->
  {parent, child, result} = {}

  beforeEach fibrous ->
    parent = Sweatshop.define fibrous ->
      @foo ?= 'herp'
      @bar ?= 'derp'

    child = parent.define fibrous ->
      @bar ?= 'slurp'

    result = child.sync.create()

  it 'borrows default attributes up the inheritance chain', ->
    expect(result.foo).to.equal 'herp'

  it 'can overwrite default attributes', ->
    expect(result.bar).to.equal 'slurp'
