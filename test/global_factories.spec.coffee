expect    = require('chai').expect
fibrous   = require 'fibrous'
Sweatshop = require '..'

describe 'the global object', ->

  it 'can create a global sweatshop', fibrous ->
    Sweatshop.define 'known', fibrous ->
      @fiz = 'buzz'

  it 'can use a global sweatshop', fibrous ->
    result = Sweatshop.sync.create('known')
    expect(result.fiz).to.equal 'buzz'

  it 'cannot use an undefined sweatshop', fibrous ->
    expect(-> Sweatshop.sync.create 'unknown').to.throw 'Unknown factory `unknown`'
