expect    = require('chai').expect
fibrous   = require 'fibrous'
Unionized = require '..'

describe 'a factory that throws exceptions', ->

  # (only 'throwing' b/c it's fibrous -- really just passing errors to callback)

  {factory, nestingFactory, childFactory} = {}

  beforeEach ->
    factory = Unionized.define (callback) ->
      process.nextTick ->
        callback new Error('this is a problem factory!')

    nestingFactory = Unionized.define (callback) ->
      @sync.embed 'errorFactory', factory    # can this work??
      callback()

    childFactory = factory.define (callback) -> callback()

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
