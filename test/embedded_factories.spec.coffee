expect    = require('chai').expect
_         = require 'lodash'
Unionized = require '../src/unionized'
async = require 'async'

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
      simpleFactory = Unionized.define @Model, (callback) ->
        @set 'val1', 'hello'
        @set 'val2', 'goodbye'
        callback()

      @embeddedFactory = Unionized.define (callback) ->
        async.series [
          (cb) => @embed 'simple1', simpleFactory, cb
          (cb) => @embed 'simple2', simpleFactory, cb
        ], (err) -> callback err

    describe 'model instantiation', ->
      describe '.json', ->
        before (done) ->
          @embeddedFactory.json (err, @result) => done err

        it 'returns plain-object instances', ->
          expect(@result.simple1.isAModel).to.be.undefined
          expect(@result.simple2.isAModel).to.be.undefined

      describe '.build', ->
        before (done) ->
          @embeddedFactory.build (err, @result) => done err

        it 'returns instances of Model', ->
          expect(@result.simple1.isAModel).to.be.true
          expect(@result.simple2.isAModel).to.be.true

        it 'does not save returned Models', ->
          expect(@result.simple1.isSaved).to.be.false
          expect(@result.simple2.isSaved).to.be.false

      describe '.create', ->
        before (done) ->
          @embeddedFactory.create (err, @result) => done err

        it 'returns instances of Model', ->
          expect(@result.simple1.isAModel).to.be.true
          expect(@result.simple2.isAModel).to.be.true

        it 'saves returned Models', ->
          expect(@result.simple1.isSaved).to.be.true
          expect(@result.simple2.isSaved).to.be.true


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


  ### NOT SUPPORTED ###
  describe.skip 'sync', ->
    before ->
      simpleFactory = Unionized.define @Model, ->
        @set 'val1', 'hello'
        @set 'val2', 'goodbye'

      @embeddedFactory = Unionized.define ->
        @embed 'simple1', simpleFactory
        @embed 'simple2', simpleFactory

    describe 'model instantiation', ->
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


  describe 'async embedding sync', ->
    before ->
      @syncFactory = Unionized.define @Model, ->
        @set 'val1', 'hello'
        @set 'val2', 'goodbye'

      @asyncFactory = Unionized.define (callback) ->
        async.series [
          (cb) => @embed 'simple1', @syncFactory, cb
          (cb) => @embed 'simple2', @syncFactory, cb
        ], (err) -> callback err

    it 'TODO'
