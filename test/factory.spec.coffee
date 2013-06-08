_       = require 'lodash'
chai    = require 'chai'
Factory = require '../factory'

expect = chai.expect

class Model
  constructor : (attrs) -> _.merge @, attrs
  save : (callback) -> callback null, @

Factory.define 'plain', (callback) ->
  @foo ?= 10
  @biz ?= fizz : 10
  callback()

Factory.define 'model', Model, (callback) ->
  await @plain? or Factory.create 'plain', @plain, defer @plain
  callback()

Factory.define 'parentModel', Model, (callback) ->
  await @model instanceof Model or Factory.create 'model', @model, defer @model
  callback()

describe 'factory', ->
  describe 'for unknown factory', ->
    it 'throws an error', ->
      expect(-> Factory.create 'unknown').to.throw 'Unknown factory `unknown`'

  describe 'for plain objects', ->
    it 'creates an object', (done) ->
      await Factory.create 'plain', defer result
      expect(result).to.be.eql foo : 10, biz : fizz : 10
      done()

    it 'adds a new property', (done) ->
      await Factory.create 'plain', { baz : 20 }, defer result
      expect(result).to.be.eql foo : 10, baz : 20, biz : fizz : 10
      done()

    it 'changes property', (done) ->
      await Factory.create 'plain', { foo : 20 }, defer result
      expect(result).to.be.eql foo : 20, biz : fizz : 10
      done()

    it 'changes property', (done) ->
      await Factory.create 'plain', { biz : fizz : 20 }, defer result
      expect(result).to.be.eql foo : 10, biz : fizz : 20
      done()

  describe 'for a model', ->
    it 'creates a model instance', (done) ->
      await Factory.create 'model', defer result
      expect(result).to.be.instanceof Model
      expect(result).to.be.eql new Model plain : foo : 10, biz : fizz : 10
      done()

    it 'adds a new property', (done) ->
      await Factory.create 'model', { foo : 20 }, defer result
      expect(result).to.be.eql new Model plain : { foo : 10, biz : fizz : 10 }, foo : 20
      done()

    it 'uses passed plain object', (done) ->
      await Factory.create 'model', { plain : foo : 20 }, defer result
      expect(result).to.be.eql new Model plain : foo : 20
      done()

  describe 'for a nested model', ->
    it 'created nested model', (done) ->
      await Factory.create 'parentModel', defer result
      expect(result).to.be.eql new Model model : new Model plain : foo : 10, biz : fizz : 10
      done()

    it 'changes nested model property', (done) ->
      await Factory.create 'parentModel', { model : plain : foo : 20 }, defer result
      expect(result).to.be.eql new Model model : new Model plain : foo : 20
      done()
