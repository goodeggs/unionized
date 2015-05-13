expect    = require('chai').expect
_         = require 'lodash'
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'embedded factories', ->
  before ->
    class @Model
      constructor: (attrs) ->
        _.merge @, attrs
      save: (callback) ->
        @isSaved = true
        callback null, @
      isAModel: yes
      isSaved: false

  describe 'async', ->
    before ->
      @simpleFactory = Unionized.define @Model, (callback) ->
        @set 'val1', 'hello'
        @set 'val2', 'goodbye'
        callback()

      @embeddedFactory = Unionized.define (callback) ->
        @embed 'simple1', @simpleFactory, =>
          @embed 'simple2', @simpleFactory, =>
            callback()

    describe 'model instantiation', ->
      describe '.create', ->
        before (done) ->
          @embeddedFactory.create (err, @result) => done err

        it 'returns instances of Model', ->
          expect(@result.simple1.isAModel).to.be.true
          expect(@result.simple2.isAModel).to.be.true

        it 'saves returned Models', ->
          expect(@result.simple1.isSaved).to.be.true
          expect(@result.simple2.isSaved).to.be.true

      describe '.build', ->
        before (done) ->
          @embeddedFactory.build (err, @result) => done err

        it 'returns instances of Model', ->
          expect(@result.simple1.isAModel).to.be.true
          expect(@result.simple2.isAModel).to.be.true

        it 'does not save returned Models', ->
          expect(@result.simple1.isSaved).to.be.false
          expect(@result.simple2.isSaved).to.be.false

      describe '.json', ->
        before (done) ->
          @embeddedFactory.json (err, @result) => done err

        it 'returns plain-object instances', ->
          expect(@result.simple1.isAModel).to.be.undefined
          expect(@result.simple2.isAModel).to.be.undefined

    describe 'overriding embedded factory values', ->
      it 'can override an entire embedded factory', (done) ->
        @embeddedFactory.json { 'simple1': 'overridden' }, (err, @result) =>
          return done err if err
          expect(@result.simple1).to.equal 'overridden'
          expect(@result.simple2).to.deep.equal val1: 'hello', val2: 'goodbye'
          done()

      it 'can override parts of an embedded factory', (done) ->
        @embeddedFactory.json { 'simple1.val1': 'greetings' }, (err, @result) =>
          return done err if err
          expect(@result.simple1).to.deep.equal val1: 'greetings', val2: 'goodbye'
          done()


  describe 'sync', ->
    before ->
      @simpleFactory = Unionized.define @Model, ->
        @set 'val1', 'hello'
        @set 'val2', 'goodbye'

      @embeddedFactory = Unionized.define ->
        @embed 'simple1', @simpleFactory
        @embed 'simple2', @simpleFactory

    describe 'model instantiation', ->
      describe '.build', ->
        before ->
          @result = @embeddedFactory.build()

        it 'returns instances of Model', ->
          expect(@result.simple1.isAModel).to.be.true
          expect(@result.simple2.isAModel).to.be.true

        it 'does not save returned Models', ->
          expect(@result.simple1.isSaved).to.be.false
          expect(@result.simple2.isSaved).to.be.false

      describe '.json', ->
        before ->
          @result = @embeddedFactory.json()

        it 'returns plain-object instances', ->
          expect(@result.simple1.isAModel).to.be.undefined
          expect(@result.simple2.isAModel).to.be.undefined

    describe 'overriding embedded factory values', ->
      it 'can override an entire embedded factory', ->
        @result = @embeddedFactory.json { 'simple1': 'overridden' }
        expect(@result.simple1).to.equal 'overridden'
        expect(@result.simple2).to.deep.equal val1: 'hello', val2: 'goodbye'

      it 'can override parts of an embedded factory', ->
        @result = @embeddedFactory.json { 'simple1.val1': 'greetings' }
        expect(@result.simple1).to.deep.equal val1: 'greetings', val2: 'goodbye'
