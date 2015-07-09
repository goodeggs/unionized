unionized = require 'unionized'
mongoose = require 'mongoose'
mongoose.connect('mongodb://localhost/test')
faker = require 'faker'

User = mongoose.model 'User', mongoose.Schema
  firstName: { type: String, required: true }
  lastName: { type: String, required: true }

userFactory = unionized.mongooseFactory(User).factory
  firstName: faker.name.firstName


userFactory.createAndSave (err, user) ->
  console.log(user)
  mongoose.disconnect()
