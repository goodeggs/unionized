[&laquo; back to README](https://github.com/goodeggs/unionized)

# Unionized API

```javascript
var factory = require('unionized');
```

The `unionized` module exports an instance of the [`Factory`](#-factory-) class.

---------------------------

## `Factory`

`Factory` contains the following public methods:

Method                                            | Description
--------------------------------------------------|-------
[`factory.factory()`](#-factory-factory-)         | Build a new factory as a child of the current factory
[`factory.create()`](#-factory-create-)           | Create an object using this factory
[`factory.createAsync()`](#-factory-createasync-) | Create an object using this factory, asynchronously

Additionally, every instance of `Factory` contains the following utility methods:

Method                                                    | Description
----------------------------------------------------------|-------
[`factory.array()`](#-factory-array-)                     | Describe the contents of an array that a factory can create
[`factory.async()`](#-factory-async-)                     | Define an asynchronous and dynamically-generated factory attribute
[`factory.enum()`](#-factory-enum-)                       | Define a list of options for a factory attribute
[`factory.mongooseFactory()`](#-factory-mongoosefactory-) | Build a new factory out of a mongoose model

`Factory` is a subtype of [`Definition`](#-definition-) &mdash;
which means you can embed factories inside other factories. More on this later.

-----------------------

### `factory.factory()`

Build a new factory out of a [`Definition`](#-definition-). Returns another instance of [`Factory`](#-factory-).

#### Usage:

```javascript
var factory = parentFactory.factory(definition)
```

#### Example:

The most common type of [`Definition`](#-definition-) to use here is a [`DotNotationObjectDefinition`](#-dotnotationobjectdefinition-), which can be coerced from an `Object` like in the following example:

```javascript
var blogFactory = factory.factory({
  title: 'How to make falafel'
  body: loremIpsumGenerator
  'metadata.tags': ['cooking', 'middle-eastern']
})
```

Once you have defined your `Factory`, you can call [`create()`](#-factory-create-) or
[`createAsync()`](#-factory-createasync-) on it to make it create an object, or
you can call `factory()` on it again to create a (generally more specific) variation on the [`Factory`](#-factory-) you
already have. For example:

```javascript
var blogFactoryByMax = blogFactory.factory({
  'metadata.author': 'Natsumi'
})
```

Now, creating an instance out of `blogFactoryByMax` will give you a blog entry
that looks like the following:

```javascript
blogFactoryByMax.create() // =>
{
  title: 'How to make falafel',
  body: 'Lorem ipsum dolor sit amet',
  metadata: {
    tags: ['cooking', 'middle-eastern'],
    author: 'Natsumi'
  },
}
```

-------

### `factory.create()`

Create an instance using this [`Factory`](#-factory-). In most cases, this
creates an instance of `Object`, but that depends on the
[`Definitions`](#-definition-) that were used to build up the
`Factory`. Optionally, also accepts a [`Definition`](#-definition`) that can be used to override existing values or add new values to the created instance.

#### Usage:

```javascript
var instance = factory.create()
var instance = factory.create(definition)
```

#### Example:

If we're starting with a `Factory` that's alredy been created:

```javascript
var creditCardFactory = factory.factory({
  type: 'Visa',
  last4: '1111',
  'exp.month': '04'
  'exp.year': '15'
})
```

...then you can create an instance and override things with `create()`:

```javascript
var card = creditCardFactory.create({
  name: 'Chloris Elisaveta'
  'exp.year': '17'
}) // =>
{
  type: 'Visa',
  last4: '1111',
  exp: {
    month: '04'
    year: '17'
  },
  name: 'Chloris Elisaveta'
}
```

If any of the [`Definitions`](#-definition-) that make up the Factory are
asynchronous, you should use [`factory.createAsync()`](#-factory-createasync-);
using `factory.create()` will throw an exception.

-------

### `factory.createAsync()`

Create an object asynchronously, using this [`Factory`](#-factory-). This method returns a `Promise` for an instance. In most cases, the instance will be an `Object`, but that depends on the
[`Definitions`](#-definition-) that were used to build up the `Factory`.
Optionally, accepts a [`Definition`](#-definition-) that can be used to override
existing values or add new values to the created instance. Optionally, also
accepts a traditional Node-style callback function which returns the instance.

This method can be used with a factory whose `Definitions` are entirely
synchronous, or with an object whose `Definitions` are asynchronous &mdash; in
either case, `createAsync()` will do its work asynchronously.

#### Usage:

```javascript
// Promises
factory.createAsync().then(function(instance) { /* ... */ })
factory.createAsync(definition).then(function(instance) { /* ... */ })

// Callbacks
factory.createAsync(function(err, instance) { /* ... */ })
factory.createAsync(definition, function(err, instance) { /* ... */ })
```

#### Example:

If we're starting with a `Factory` that's already been created:

```javascript
var request = require('request');
var quoteSource = 'http://www.iheartquotes.com/api/v1/random';
var quoteFactory = factory.factory({
  content: factory.async(function (done) {
    request(quoteSource, function(err, response, body) { done(err, body) });
  }),
  source: quoteSource
});
```

...then you can create an instance and override things with `createAsync()`:

```javascript
var promise = quoteFactory.createAsync({createdAt: new Date()})
promise.then(function (quote) {
  quote // =>
  {
    content: "A man who turns green has eschewed protein.",
    source: "http://www.iheartquotes.com/api/v1/random",
    createdAt: '2015-05-18T06:17:16.989Z'
  }
})
```

-------

### `factory.array()`

-------

### `factory.async()`

-------

### `factory.enum()`

-------

### `factory.mongooseFactory()`

------

## `Definition`


