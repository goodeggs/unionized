_         = require 'lodash'
chai      = require 'chai'
fibrous   = require 'fibrous'
Sweatshop = require '../sweatshop.js'

expect = chai.expect

class Model
  constructor: (attrs) -> _.merge @, attrs
  save: (callback) -> callback null, @

Sweatshop.define 'plain', (callback) ->
  @foo ?= 10
  @biz ?= fizz: 10
  callback()

Sweatshop.define 'model', Model, fibrous ->
  @plain ?= Sweatshop.sync.create 'plain'

Sweatshop.define 'parentModel', Model, fibrous ->
  @model = Sweatshop.sync.create 'model', @model unless @model instanceof Model

describe 'sweatshop', ->
  describe 'for unknown factory', ->
    it 'throws an error', ->
      expect(-> Sweatshop.sync.create 'unknown').to.throw 'Unknown factory `unknown`'

  describe 'for plain objects', ->
    it 'creates an object', fibrous ->
      result = Sweatshop.sync.create 'plain'
      expect(result).to.be.eql foo: 10, biz: fizz: 10

    it 'adds a new property', fibrous ->
      result = Sweatshop.sync.create 'plain', {baz: 20}
      expect(result).to.be.eql foo: 10, baz: 20, biz: fizz: 10

    it 'changes property', fibrous ->
      result = Sweatshop.sync.create 'plain', {foo: 20}
      expect(result).to.be.eql foo: 20, biz: fizz: 10

    it 'changes property', fibrous ->
      result = Sweatshop.sync.create 'plain', {biz: fizz: 20}
      expect(result).to.be.eql foo: 10, biz: fizz: 20

  describe 'for a model', ->
    it 'creates a model instance', fibrous ->
      result = Sweatshop.sync.create 'model'
      expect(result).to.be.instanceof Model
      expect(result).to.be.eql new Model plain: foo: 10, biz: fizz: 10

    it 'adds a new property', fibrous ->
      result = Sweatshop.sync.create 'model', {foo: 20}
      expect(result).to.be.eql new Model plain: {foo: 10, biz: fizz: 10}, foo: 20

    it 'uses passed plain object', fibrous ->
      result = Sweatshop.sync.create 'model', {plain: foo: 20}
      expect(result).to.be.eql new Model plain: foo: 20

  describe 'for a nested model', ->
    it 'created nested model', fibrous ->
      result = Sweatshop.sync.create 'parentModel'
      expect(result).to.be.eql new Model model: new Model plain: foo: 10, biz: fizz: 10

    it 'changes nested model property', fibrous ->
      result = Sweatshop.sync.create 'parentModel', {model: plain: foo: 20}
      expect(result).to.be.eql new Model model: new Model plain: foo: 20
