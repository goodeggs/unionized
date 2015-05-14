expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'factories with arguments', ->
  {factory} = {}

  describe 'a factory that creates an object whose values are dependent on other values', ->

    describe 'async', ->
      beforeEach ->
        factory = Unionized.define (callback) ->
          foobar = @args[0]
          @set 'foo.bar', foobar
          @set 'baz', 10
          callback()

      it 'passes arguments into the factory function', (done) ->
        factory.json {}, 12, (err, result) ->
          return done err if err
          expect(result.foo.bar).to.equal 12
          done()

      it 'sets the default values properly', (done) ->
        factory.json {}, 12, (err, result) ->
          return done err if err
          expect(result.baz).to.equal 10
          done()

    describe 'sync', ->
      beforeEach ->
        factory = Unionized.define ->
          foobar = @args[0]
          @set 'foo.bar', foobar
          @set 'baz', 10

      it 'passes arguments into the factory function', ->
        result = factory.json {}, 12
        expect(result.foo.bar).to.equal 12

      it 'sets the default values properly', ->
        result = factory.json {}, 12
        expect(result.baz).to.equal 10
