expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a factory that throws exceptions', ->
  {factory, nestingFactory, childFactory} = {}

  beforeEach ->
    factory = Unionized.define fibrous ->
      throw new Error('this is a problem factory!')

    nestingFactory = Unionized.define fibrous ->
      @sync.embed 'errorFactory', factory

    childFactory = factory.define fibrous ->

  it 'throws an error when JSON\'d up', fibrous ->
    expect(-> factory.sync.json()).to.throw Error

  it 'throws an error when built', fibrous ->
    expect(-> factory.sync.build()).to.throw Error

  it 'throws an error when created', fibrous ->
    expect(-> factory.sync.create()).to.throw Error

  it 'throws an error when an embedded factory throws an error', fibrous ->
    expect(-> nestingFactory.sync.json()).to.throw Error

  it 'throws an error when a factory‘s parent throws an error', fibrous ->
    expect(-> childFactory.sync.json()).to.throw Error
