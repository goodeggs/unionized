unionized = require 'unionized'
faker = require 'faker'

userFactory = unionized.factory
  firstName: faker.name.firstName
  lastName: faker.name.lastName

console.log userFactory.create()
