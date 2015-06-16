require './test_setup'
orderEventHandler = require './order_event_handler'

it 'handles an order.created event', ->
  result = orderEventHandler(
    name: 'order.created'
    occurredAt: '2015-05-01T07:00:00.000Z'
    refs:
      orderId: '55567e335051a48a810001b5'
      userId: '83431d55b6ca450206300efa'
    args:
      order:
        id: '55567e335051a48a810001b5'
        status: 'placed'
        orderCutoff: '2015-06-02T07:00:00.000Z'
        user: '83431d55b6ca450206300efa'
        foodshed: 'sfbay'
        fulfillmentDay: '2015-06-16'
        deliveryWindow:
          startAt: '2015-06-03T22:00:00.000Z'
          endAt: '2015-06-04T00:00:00.000Z'
        totals:
          subtotal: 7281
          discount: 599
          delivery: 399
          total: 7081
        isGift: false
        hasColdPackaging: true
        delivery: true
        deliveryDetails:
          deliveryInstructions: 'Unit in rear, behind 460'
          address: '458 44th St'
          city: 'Oakland'
          state: 'CA'
          zip: '94609'
          lat: 37.8324736
          lng: -122.2611869
        items: [
          {
            quantity: 1
            unit: '3 large avocados'
            subtotal: 599
            editableUntil: '2015-06-02T07:00:00.000Z'
            product:
              id: '546a15f2c5c77f0200001de5'
              slug: 'medium-hass-avocado-trio'
              name: 'Medium Hass Avocado Trio'
              price: 599
              isBundle: false
              photo:
                key: 'product_photos/KG5jgbGWRKuvgRYSxeBO_FK1A9369.jpg'
              vendor:
                id: '5159faf8c8d2ec0200000129'
                name: 'Stepladder Ranch'
                slug: 'stepladderranch'
          }
          {
            quantity: 1
            unit: 'half dozen'
            subtotal: 449
            editableUntil: '2015-06-02T07:00:00.000Z'
            product:
              id: '5140e33119b519020000585d'
              slug: 'half-dozen-organic-pastured-eggs'
              name: 'Half Dozen Organic Pastured Eggs'
              price: 449
              isBundle: false
              photo:
                key: 'product_photos/YeUlWcVKRsmnd3SJxBMu_FK1A7084.jpg'
              vendor:
                id: '5136aa478c482002000183c4'
                name: 'Red Hill Farms'
                slug: 'redhillfarms'
          }
        ]
  )
  expect(result).to.be.ok
