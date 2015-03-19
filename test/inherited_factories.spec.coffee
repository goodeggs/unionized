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

  it 'borrows default attributes up the inheritance chain', ->
    expect(@child.foo).to.equal 'herp'

  it 'can overwrite default attributes', ->
    expect(@child.bar).to.equal 'slurp'

  it 'can inherit from grandparents', ->
    expect(@grandChild.boom).to.equal 'pow'
    expect(@grandChild.bar).to.equal 'slurp'
    expect(@grandChild.foo).to.equal 'herp'
