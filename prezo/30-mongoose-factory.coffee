unionized = require 'unionized'
mongoose = require 'mongoose'
mongoose.connect('mongodb://localhost/test')

User = mongoose.model 'User', mongoose.Schema
  firstName: { type: String, required: true }
  lastName: { type: String, required: true }

userFactory = unionized.mongooseFactory(User)

userFactory.createAndSave (err, user) ->
  console.log(user)
  mongoose.disconnect()
