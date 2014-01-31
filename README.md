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
pickupFactory = unionized.define(function() {
  this.set('pickup.pickupWindow.startAt', '2pm');
  this.set('pickup.pickupWindow.endAt', '4pm');
  this.set('pickup.name', 'San Francisco Ferry Building');
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

# License

[The MIT License (MIT)](https://github.com/goodeggs/unionized/blob/master/LICENSE)
