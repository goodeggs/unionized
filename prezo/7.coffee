# Use case #1: Really simple/straightforward definition syntax

unionized = require '..'
faker = require 'faker'

userFactory = unionized.factory
  firstName: faker.name.firstName
  lastName: faker.name.lastName
  phone: -> faker.helpers.replaceSymbolWithNumber('+1##########')
  stripe:
    customer:
      id: 'cus_1M7oD5WStQ3iGo'
      active_card:
        fingerprint: 'tzLLKdDunxYxcuiU'
        exp_month: 12
        exp_year: 2031
        last4: '4242'
        type: 'Visa'

console.log JSON.stringify userFactory.create(), null, 2
console.log JSON.stringify userFactory.create(), null, 2
