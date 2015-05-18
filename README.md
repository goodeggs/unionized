# Unionized

Unionized is a library for setting up JavaScript objects as test data. Compare to the [factory_girl](https://github.com/thoughtbot/factory_girl) Ruby gem by [thoughtbot](https://thoughtbot.com/open-source).

[![NPM
version](https://img.shields.io/npm/v/unionized.svg)](https://www.npmjs.com/package/unionized)
[![NPM
license](https://img.shields.io/npm/l/express.svg)](https://img.shields.io/travis/joyent/node.svg)
[![Dependency status](https://img.shields.io/david/goodeggs/unionized.svg)](https://david-dm.org/goodeggs/unionized)
[![Build Status](https://img.shields.io/travis/goodeggs/unionized.svg)](https://travis-ci.org/goodeggs/unionized)

# Links

- Installation Instructions
- API Documentation

# Examples

**Define** a factory:

```javascript
var humanFactory = unionized.factory({
  name: {
    first: unionized.enum(['Azrael', 'Bastiaan', 'Laurentiu', 'Gerolf']),
    last: 'Smithy'
  },
  birthdate: function() { return new Date() }
})
```

Use that factory to **create instances**:

```javascript
var human = humanFactory.create()
/*
 { name: { first: 'Gerolf', last: 'Smithy' }
   birthdate: Sun May 17 2015 16:52:25 GMT-0700 (PDT) }
*/
```

You can **override the defaults** if you like, using **dot notation**:

```javascript
var chen = humanFactory.create({ 'name.first': 'Chen' })
/*
 { name: { first: 'Chen', last: 'Smithy' }
   birthdate: Sun May 17 2015 16:58:19 GMT-0700 (PDT) }
*/
```

You might want factories that are **composed out of other factories**:

```javascript
var organizationFactory = unionized.factory({
  name: 'Board Game Club',
  members: unionized.array(humanFactory, 4)
})
organizationFactory.create()
/*
 { name: 'Board Game Club',
   members: [
     { name: { first: 'Bastiaan', last: 'Smithy' },
       birthdate: Sun May 17 2015 17:09:52 GMT-0700 (PDT) },
     { name: { first: 'Azrael', last: 'Smithy' },
       birthdate: Sun May 17 2015 17:09:52 GMT-0700 (PDT) }
     { name: { first: 'Gerolf', last: 'Smithy' },
       birthdate: Sun May 17 2015 17:09:52 GMT-0700 (PDT) }
     { name: { first: 'Bastiaan', last: 'Smithy' },
       birthdate: Sun May 17 2015 17:09:52 GMT-0700 (PDT) }
   ] }
*/
```

More features you may be interested in:

- Factory inheritance
- Auto-generating factories from database schemas (currently we only support mongoose)
- Asynchronous factories

# License

[The MIT License (MIT)](https://github.com/goodeggs/unionized/blob/master/LICENSE)
