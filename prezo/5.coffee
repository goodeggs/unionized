# the Factory object

user = Factory.create 'user', stripe: Factory.create 'userStripeDoc'

# definition:

Factory.define 'user', User, (actors = {}) ->
  actors.firstName ?= faker.name.firstName()
  actors.lastName ?= faker.name.lastName()
  actors.phone ?= if actors.phone is undefined then helpers.replaceSymbolWithNumber '+1##########' else actors.phone
  actors.zip ?= faker.address.zipCode()
  actors.foodshed = if actors.foodshed is undefined then 'sfbay' else actors.foodshed
  actors.email ?= faker.uniq 'userEmail', faker.internet.email.bind(faker.internet)
  actors.passwordHash ?= '$2a$10$iZ8vqtQX66vOEY7/OOVcuB0B8Cu/WDan9FUm.hH8Hq0kAVw1G5n2' # password1
  actors

Factory.define 'userStripeDoc', Object,
  customer:
    id: 'cus_1M7oD5WStQ3iGo'
    active_card:
      fingerprint: 'tzLLKdDunxYxcuiU'
      exp_month: 12
      exp_year: 2031
      last4: '4242'
      type: 'Visa'

# fancy DB footwork -- calling create doesn't create the object in mongodb
# UNLESS the test accesses the database

# you also have create() and build() for more control

# but what if you want to do something like:

Factory.create 'userStripeDoc', { customer: id: '12345' } # NOPE

# finally, embedding of factories can get really confusing
# the solution to this is probably to decouple your entities more
# but things could still be better.
