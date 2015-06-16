unionized = require 'unionized'
faker = require 'faker'

userFactory = unionized
  .factory
    firstName: faker.name.firstName
    lastName: faker.name.lastName
  .onCreate (user) ->
    user.fullName = "#{user.firstName} #{user.lastName}"
    user

console.log userFactory.create()
