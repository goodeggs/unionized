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

  it 'cannot use an undefined factory', ->
    expect(-> Unionized.sync.create 'unknown').to.throw 'Unknown factory `unknown`'