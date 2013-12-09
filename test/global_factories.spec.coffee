expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'the global object', ->

  it 'can create a global factory', fibrous ->
    Unionized.define 'known', fibrous ->
      @set 'fiz', 'buzz'

  it 'can use a global factory', fibrous ->
    result = Unionized.sync.create('known')
    expect(result.fiz).to.equal 'buzz'

  it 'cannot use an undefined factory', fibrous ->
    expect(-> Unionized.sync.create 'unknown').to.throw 'Unknown factory `unknown`'
