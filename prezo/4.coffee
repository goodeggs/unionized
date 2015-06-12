# the buildCustomer function

buildCustomer = (attrs) ->
  _(
    object: "customer"
    created: 1338252831
    id: "cus_1M7oD5WStQ3iGo"
    active_card:
      object: "card",
      type: "Visa",
      exp_month: 4,
      exp_year: 2013,
      last4: "4779",
  ).extend(attrs)

# allows you to do the following:

@sinon.stub(stripe.customers.sync, 'create').returns buildCustomer()

buildCustomer({id: 'cus_awesomepossum'})

# but what about this???

buildCustomer({activeCard: {last4: "3311"}})
