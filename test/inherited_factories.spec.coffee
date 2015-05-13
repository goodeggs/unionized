expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'inherited factories', ->
  beforeEach fibrous ->
    parent = Unionized.define fibrous ->
      @set 'foo', 'herp'
      @set 'bar', 'derp'

    child = parent.define fibrous ->
      @set 'bar', 'slurp'

    grandChild = child.define fibrous ->
      @set 'boom', 'pow'

    @child = child.sync.create()
    @grandChild = grandChild.sync.create()
    @babyGrandChild = grandChild.sync.create(
      foo: 'baby'
      boom: 'waaah'
    )

  it 'borrows default attributes up the inheritance chain', ->
    expect(@child).to.have.property 'foo', 'herp'

  it 'can overwrite default attributes', ->
    expect(@child).to.have.property 'bar', 'slurp'

  it 'can inherit from grandparents', ->
    expect(@grandChild).to.have.property 'boom', 'pow'
    expect(@grandChild).to.have.property 'bar', 'slurp'
    expect(@grandChild).to.have.property 'foo', 'herp'

  it 'can pass arguments', ->
    expect(@babyGrandChild).to.have.property 'foo', 'baby'
    expect(@babyGrandChild).to.have.property 'boom', 'waaah'
    expect(@babyGrandChild).to.have.property 'bar', 'slurp'