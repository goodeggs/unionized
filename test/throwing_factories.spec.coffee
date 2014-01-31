expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a factory that throws exceptions', ->
  {factory} = {}

  beforeEach ->
    factory = Unionized.define fibrous ->
      throw new Error('this is a problem factory!')

  it 'throws an error when JSON\'d up', fibrous ->
    expect(-> factory.sync.json()).to.throw Error

  it 'throws an error when built', fibrous ->
    expect(-> factory.sync.build()).to.throw Error

  it 'throws an error when created', fibrous ->
    expect(-> factory.sync.create()).to.throw Error
