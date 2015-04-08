# Unionized

A user-friendly factory system for easily building up complex objects. Entirely asynchronous.
Recommended for use in testing, but you never know where else this could be useful!

[![NPM version](https://badge.fury.io/js/unionized.png)](http://badge.fury.io/js/unionized)
[![Dependency status](https://david-dm.org/goodeggs/unionized.png)](https://david-dm.org/goodeggs/unionized)
[![Build Status](https://travis-ci.org/goodeggs/unionized.png)](https://travis-ci.org/goodeggs/unionized)
[![Coverage Status](https://coveralls.io/repos/goodeggs/unionized/badge.png?branch=master)](https://coveralls.io/r/goodeggs/unionized?branch=master)

# Usage

Create complex objects really easily:

```javascript

var unionized = require('unionized');
unionized.create({
  'pickup.pickupWindow.startAt': '2pm',
  'pickup.pickupWindow.endAt': '4pm',
  'pickup.name': 'San Francisco Ferry Building'
}, function(err, result) { console.log(result); });

// prints:
//   {
//      pickup: {
//        pickupWindow: {
//          startAt: '2pm',
//          endAt: '4pm',
//        },
//        name: 'San Francisco Ferry Building'
//     }
//   }
```

...or, better, define factories to create those objects for you:

```javascript
var pickupFactory = unionized.define(function(done) {
  this.set('pickup.pickupWindow.startAt', '2pm');
  this.set('pickup.pickupWindow.endAt', '4pm');
  this.set('pickup.name', 'San Francisco Ferry Building');
  done();
});
pickupFactory.create(function(err, result) { console.log(result); });

// prints:
//   {
//      pickup: {
//        pickupWindow: {
//          startAt: '2pm',
//          endAt: '4pm',
//        },
//        name: 'San Francisco Ferry Building'
//     }
//   }
```

now we can customize the objects that our factory returns us:

```javascript
pickupFactory.create({
  'pickup.pickupWindow.startAt': '1am',
  'options.caveats': 'Customers are expected to bring their own shopping bags'
}, function(err, result) { console.log(result); });

// prints:
//   {
//      pickup: {
//        pickupWindow: {
//          startAt: '1am',
//          endAt: '4pm',
//        },
//        name: 'San Francisco Ferry Building'
//      },
//      options: {
//        caveats: 'Customers are expected to bring their own shopping bags'
//      }
//   }
```

We can also embed factories inside other factories:

```javascript
var orderFactory = unionized.define(function(done) {
  this.set('customer', 'Lex Luthor');
  this.set('total', 3.50);
  this.embed('deliveryDetails', pickupFactory, done);
});
orderFactory.create(function(err, result) { console.log(result); });

// prints:
//    {
//      customer: "Lex Luthor",
//      total: 3.50,
//      deliveryDetails: {
//        pickup: {
//          pickupWindow: {
//            startAt: '2pm',
//            endAt: '4pm',
//          },
//          name: 'San Francisco Ferry Building'
//        }
//      }
//    }
```

And we can create factories that extend and modify other factories:

```javascript
var lateNightPickupFactory = pickupFactory.define(function(done) {
  this.set('pickupWindow.startAt', '11pm');
  this.set('pickupWindow.endAt', '12am');
  done();
});
lateNightPickupFactory.create(function(err, result) { console.log(result); });

// prints:
//   {
//      pickup: {
//        pickupWindow: {
//          startAt: '11pm',
//          endAt: '12am',
//        },
//        name: 'San Francisco Ferry Building'
//     }
//   }

```

If using `.json()`, you can optionally define and instantiate factories
synchronously.

```javascript
var pickupFactory = unionized.define(function() {
  this.set('pickupWindow.startAt', '11pm');
  this.set('pickupWindow.endAt', '12am');
});
result = lateNightPickupFactory.json();
console.log(result);

// prints:
//   {
//      pickup: {
//        pickupWindow: {
//          startAt: '11pm',
//          endAt: '12am'
//        }
//     }
//   }
```

Arrays are simple too!

```javascript
var repeatingFactory = unionized.define(function(done) {
  this.setArray('repeating', 3, ['a', 'b']);
});
console.log(repeatingFactory.json());

// prints:
// { repeating: [ 'a', 'b', 'a' ] }
```

Embedded arrays are just another parameter away.

```javascript
// using previously defined `pickupFactory`
var pickupOptionsFactory = unionized.define(function(done) {
  this.embedArray('pickupChoices', 3, pickupFactory, done);
});
```

# License

[The MIT License (MIT)](https://github.com/goodeggs/unionized/blob/master/LICENSE)
