expect = require('chai').expect
Promise = require 'bluebird'
unionized = require '..'

it 'can create an object using dot notation', ->
  result = unionized.create
    'do': 'wop'
    'foo.bar': 'baz'
    'foo.biz': 'buzz'
  expect(result.do).to.equal 'wop'
  expect(result.foo.bar).to.equal 'baz'
  expect(result.foo.biz).to.equal 'buzz'

it 'can create a factory', ->
  factory = unionized.factory
    'do': 'wop'
    'foo.bar': 'baz'
    'foo.biz': 'buzz'
  result = factory.create()
  expect(result.do).to.equal 'wop'
  expect(result.foo.bar).to.equal 'baz'
  expect(result.foo.biz).to.equal 'buzz'

it 'can override factory parameters', ->
  factory = unionized.factory
    'do': 'wop'
    'foo.bar': 'baz'
    'foo.biz': 'buzz'
  result = factory.create
    'foo.bar': 'zab'
    'grue': 'snork'
  expect(result.do).to.equal 'wop'
  expect(result.foo.bar).to.equal 'zab'
  expect(result.foo.biz).to.equal 'buzz'
  expect(result.grue).to.equal 'snork'

it 'can create child factories', ->
  parentFactory = unionized.factory
    'do': 'wop'
    'foo.bar': 'baz'
    'foo.biz': 'buzz'
  childFactory = parentFactory.factory
    'foo.bar': 'zab'
    'grue': 'snork'
  result = childFactory.create()
  expect(result.do).to.equal 'wop'
  expect(result.foo.bar).to.equal 'zab'
  expect(result.foo.biz).to.equal 'buzz'
  expect(result.grue).to.equal 'snork'

it 'can pass in functions', ->
  result = unionized.create
    'foo.bar': -> 'baz'
  expect(result.foo.bar).to.equal 'baz'

it 'can pass in async functions', (testDone) ->
  asyncFunctionHasRun = false
  asyncFactory = unionized.factory
    'foo.bar': unionized.async (propReady) ->
      asyncFunctionHasRun = true
      propReady(null, 'baz')
  expect(asyncFunctionHasRun).to.be.false
  asyncFactory.createAsync (err, result) ->
    return testDone(err) if err
    expect(result.foo.bar).to.equal 'baz'
    testDone()

it 'can pass in promises',  (testDone) ->
  asyncFactory = unionized.factory
    'foo.bar': new Promise (resolve, reject) -> resolve 'baz'
  asyncFactory.createAsync (err, result) ->
    return testDone(err) if err
    expect(result.foo.bar).to.equal 'baz'
    testDone()

it 'can pass in promises that are created within functions', (testDone) ->
  asyncFactory = unionized.factory
    'foo.bar': -> new Promise (resolve, reject) -> resolve 'baz'
  asyncFactory.createAsync (err, result) ->
    return testDone(err) if err
    expect(result.foo.bar).to.equal 'baz'
    testDone()

it 'can pass in other factories', ->
  componentFactory = unionized.factory
    'bar': 'baz'
  compositeFactory = unionized.factory
    'foo': componentFactory
  result = compositeFactory.create()
  expect(result.foo.bar).to.equal 'baz'

it 'can override objects passed into child factories from the parent factory', ->
  childFactory = unionized.factory
    'bar': 'baz'
    'do': 'wop'
  factory = unionized.factory
    'foo': childFactory
  result = factory.create
    'foo.bar': 'spuz'
  expect(result.foo.bar).to.equal 'spuz'
  expect(result.foo.do).to.equal 'wop'

it 'can pass in configurable arrays', ->
  factory = unionized.factory
    'arr': [1,2,3]
  expect(factory.create('arr[]': 1).arr).to.deep.equal [1]
  expect(factory.create('arr[]': 2).arr).to.deep.equal [1, 2]
  expect(factory.create('arr[]': 3).arr).to.deep.equal [1, 2, 3]
  expect(factory.create('arr[]': 4).arr).to.deep.equal [1, 2, 3, 1]
  expect(factory.create('arr[1]': 5).arr).to.deep.equal [1, 5, 3]

it 'can pass in arrays of other factories', ->
  childFactory = unionized.factory
    'bar': 'baz'
  factory = unionized.factory
    'arr': unionized.array childFactory, 3
  expect(factory.create().arr).to.deep.equal [{bar: 'baz'}, {bar: 'baz'}, {bar: 'baz'}]

it 'can pass in arrays of async factories', (testDone) ->
  childFactory = unionized.factory
    'bar': -> new Promise (resolve) -> resolve 'baz'
  factory = unionized.factory
    'arr': unionized.array childFactory, 3
  factory.createAsync (err, result) ->
    return testDone(err) if err
    expect(result.arr).to.deep.equal [{bar: 'baz'}, {bar: 'baz'}, {bar: 'baz'}]
    testDone()
