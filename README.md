# Unionized

A user-friendly factory system for easily building up complex objects.
Can be either synchronous or asynchronous.
Recommended for use in testing, but you never know where else this could be useful!

[![NPM version](https://badge.fury.io/js/unionized.png)](http://badge.fury.io/js/unionized)
[![Dependency status](https://david-dm.org/goodeggs/unionized.png)](https://david-dm.org/goodeggs/unionized)
[![Build Status](https://travis-ci.org/goodeggs/unionized.png)](https://travis-ci.org/goodeggs/unionized)

# Usage

Create complex objects really easily:

```javascript
var unionized = require('unionized');
unionized.create({
  'pickup.pickupWindow.startAt': '2pm',
  'pickup.pickupWindow.endAt': '4pm',
  'pickup.name': 'San Francisco Ferry Building'
})

// creates:
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
var pickupFactory = unionized.factory({
  'pickup.pickupWindow.startAt': '2pm',
  'pickup.pickupWindow.endAt': '4pm',
  'pickup.name': 'San Francisco Ferry Building'
})
pickupFactory.create()

// creates:
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

We can override results on created factories:

```javascript
pickupFactory.create({
  'pickup.pickupWindow.startAt': '1am',
  'options.caveats': 'Customers are expected to bring their own shopping bags'
})

//creates:
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

We can create objects dynamically:

```javascript
pickupFactory.create({
  'pickup.pickupWindow.startAt': -> clock.now()
})
```

We can create objects **asynchronously**, too:

```javascript
var request = require('request')
var pickupFactory = unionized.factory({
  'pickup.pickupWindow.startAt': '2pm',
  'pickup.pickupWindow.endAt': '4pm',
  'pickup.websiteContents': unionized.async(function(propReady) {
    request('https://goodeggs.com', function(error, response, body) { propReady(error, body) })
   })
})
pickupFactory.createAsync(
  {'pickup.name': 'San Francisco Ferry Building'},
  function(error, pickup) {
    console.log(pickup.websiteContents)
  }
)
```

Asynchronous objects can also be created using promises:

```javascript
var pickupFactory = unionized.factory({
  'pickup.pickupWindow.startAt': '2pm',
  'pickup.pickupWindow.endAt': '4pm',
  'pickup.websiteContents': -> jQuery.ajax('https://goodeggs.com')
})
pickupFactory.createAsync({'pickup.name': 'San Francisco Ferry Building'})
  .then(function(pickup) {
    console.log(pickup.websiteContents)
  })
```

We can also embed factories inside other factories:

```javascript
var orderFactory = unionized.factory({
  'customer': 'Lex Luthor'
  'total': 3.50
  'deliveryDetails': pickupFactory
});
orderFactory.create()

// creates:
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
var lateNightPickupFactory = pickupFactory.factory({
  'pickupWindow.startAt': '11pm'
  'pickupWindow.endAt': '12am'
});
lateNightPickupFactory.create();

// creates:
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


The main **methods** on a factory are:
 
1. `create`: Use with database models that have a `save` method, this will save a real record to the database.
  (For async factories only.)
    
2. `build`: Also used with database models, but only returns a model, does not save it to the database.
  (For async factories only.)

3. `json`: Generate a plain ol' object. Sync or async.


The **factory function** itself can either take 1 argument (a callback, implies an async interface),
or 0 arguments, for a sync interface.
You can pass additional parameters to your factory functions - e.g. `factory.create(attrs, extra1, extra2, callback)` -
and your factory function can access the extra parameters by introspecting `this.args`.


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
  this.embedArray('choices', 3, pickupFactory, done);
});

// prints:
// { choices: [
//   { pickup: [Object] },
//   { pickup: [Object] },
//   { pickup: [Object] }
//   ]
// }
```

# License

[The MIT License (MIT)](https://github.com/goodeggs/unionized/blob/master/LICENSE)
