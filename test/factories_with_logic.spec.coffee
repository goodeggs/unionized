expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'factories with logic', ->
  {factory} = {}

  describe 'a factory that creates an object whose values are dependent on other values', ->
    describe 'async', ->
      beforeEach ->
        factory = Unionized.define (callback) ->
          @set 'smaller', 10
          @set 'larger', @get('smaller') + 10
          @set 'foo.bar', 12
          callback()

      it 'sets the default values properly', (done) ->
        factory.json (err, result) ->
          return done err if err
          expect(result.smaller).to.equal 10
          expect(result.larger).to.equal 20
          done()

      it 'sets the dependent value based on input', (done) ->
        factory.json { smaller: 20 }, (err, result) ->
          return done err if err
          expect(result.smaller).to.equal 20
          expect(result.larger).to.equal 30
          done()

      it 'overrides the logic value', (done) ->
        factory.json { larger: 2000 }, (err, result) ->
          return done err if err
          expect(result.larger).to.equal 2000
          done()


    describe 'sync', ->
      beforeEach ->
        factory = Unionized.define ->
          @set 'smaller', 10
          @set 'larger', @get('smaller') + 10
          @set 'foo.bar', 12

      it 'sets the default values properly', ->
        result = factory.json()
        expect(result.smaller).to.equal 10
        expect(result.larger).to.equal 20

      it 'sets the dependent value based on input', ->
        result = factory.json smaller: 20
        expect(result.smaller).to.equal 20
        expect(result.larger).to.equal 30

      it 'overrides the logic value', fibrous ->
        result = factory.json larger: 2000
        expect(result.larger).to.equal 2000
