# Sweatshop

Very basic factories helper to generate plain objects and scenarios for tests.

# Usage Example

```javascript
# Basic models
Sweatshop.define 'user', User, (done) ->
  @username  ?= Faker.Helpers.replaceSymbolWithNumber("facebook-##########")
  @name      ?= "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
  @picture   ?= "http://www.gravatar.com/avatar/#{md5 Math.random().toString()}?d=identicon&f=y"
  @email     ?= Faker.Internet.email()
  @createdAt ?= new Date()

  done()

Sweatshop.define 'page', Page, (done) ->
  @identifier   ?= Faker.Internet.slug()
  @url          ?= Faker.Internet.url()
  @createdAt    ?= new Date()
  @messageCount ?= 0

  done()

# Complex model
Sweatshop.define 'message', Message, (done) ->
  @page       = Sweatshop.sync.create 'page', @page unless @page instanceof Page
  @author     = Sweatshop.sync.create 'user', @author unless @author instanceof User
  @identifier ?= Faker.Internet.slug()
  @body       ?= Faker.Lorem.sentences 1 + rnd 3
  @createdAt  ?= new Date()

  done()

# Scenario example
Sweatshop.define 'page with comments', (done) ->
  @user1         = Sweatshop.sync.create 'user'
  @user2         = Sweatshop.sync.create 'user'
  @user3         = Sweatshop.sync.create 'user'
  @page          = Sweatshop.sync.create 'page'
  @message_1     = Sweatshop.sync.create 'message', {@page, author: @user1, createdAt: new Date('2013-03-03 10:00')}
  @message_1_1   = Sweatshop.sync.create 'message', {@page, author: @user2, parent: @message_1}
  @message_1_1_1 = Sweatshop.sync.create 'message', {@page, author: @user3, parent: @message_1_1}
  @message_1_2   = Sweatshop.sync.create 'message', {@page, author: @user3, parent: @message_1}
  @message_2     = Sweatshop.sync.create 'message', {@page, author: @user2, createdAt: new Date('2013-03-03 9:00')}
  @message_2_1   = Sweatshop.sync.create 'message', {@page, author: @user3, parent: @message_2}

  done()

# Basic syntax
Sweatshop.create 'user' #=> {username, name, picture, email, createdAt}

# Creating submodels
Sweatshop.create 'message', {page: {identifier, url}} #=> {page, author, identifier, body, createdAt}

# Using already created models
page = new Page attrs
Sweatshop.create 'message', {page} #=> {page, author, identifier, body, createdAt}
```
