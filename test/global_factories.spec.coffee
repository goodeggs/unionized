expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'the global object', ->

  it 'can create a global factory', ->
    Unionized.define 'known', (callback) ->
      @set 'fiz', 'buzz'
      callback()

  it 'can use a global factory', (done) ->
    Unionized.create 'known', (err, result) ->
      return done err if err
      expect(result.fiz).to.equal 'buzz'
      done()

  it 'cannot use an undefined factory', (done) ->
    Unionized.sync.create 'unknown', (err, result) ->
      expect(err).to.be.an.instanceof Error
      expect(err.message).to.equal 'Unknown factory `unknown`'
      expect(result).not.to.be.ok
      done()