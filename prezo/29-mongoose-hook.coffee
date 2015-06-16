unionized = require 'unionized'
faker = require 'faker'
mongoose = require 'mongoose'

User = mongoose.model 'User', mongoose.Schema
  firstName: { type: String, required: true }
  lastName: { type: String, required: true }

userFactory = unionized
  .factory
    firstName: faker.name.firstName
    lastName: faker.name.lastName
  .onCreate (user) -> new User(user)

console.log userFactory.create()
