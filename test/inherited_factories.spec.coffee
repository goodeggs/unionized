expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'inherited factories', ->
  describe 'async', ->
    beforeEach fibrous ->
      parent = Unionized.define (callback) ->
        @set 'foo', 'herp'
        @set 'bar', 'derp'
        callback()

      child = parent.define (callback) ->
        @set 'bar', 'slurp'
        callback()

      grandChild = child.define (callback) ->
        @set 'boom', 'pow'
        callback()

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


  describe 'sync', ->
    beforeEach ->
      parent = Unionized.define ->
        @set 'foo', 'herp'
        @set 'bar', 'derp'

      child = parent.define ->
        @set 'bar', 'slurp'

      grandChild = child.define ->
        @set 'boom', 'pow'

      @child = child.build()
      @grandChild = grandChild.build()
      @babyGrandChild = grandChild.build(
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


  describe 'async inheriting from sync', ->
    beforeEach (done) ->
      syncParent = Unionized.define ->
        @set 'foo', 'herp'

      asyncChild = syncParent.define (callback) ->
        @set 'bar', 'slurp'
        process.nextTick -> callback()

      asyncChild.build (err, @result) => done err

    it 'is ok', ->
      expect(@child).to.be.ok
      expect(@child).to.have.property 'foo', 'herp'
      expect(@child).to.have.property 'bar', 'slurp'


  describe 'sync inheriting from async', ->
    it 'is invalid', ->
      asyncParent = Unionized.define (callback) ->
        @set 'bar', 'slurp'
        process.nextTick -> callback()

      expect(-> asyncParent.define (->)).to.throw /cannot.*async/i

