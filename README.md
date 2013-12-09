# Unionized

Very basic factories helper to generate plain objects and scenarios for tests.

[![Dependency status](https://david-dm.org/demands/unionized.png)](https://david-dm.org/demands/unionized) [![Build Status](https://travis-ci.org/demands/unionized.png)](https://travis-ci.org/demands/unionized)

# Usage Example

Unionized is geared towards CoffeeScript syntax and is especially clean with the
amazing [fibrous](https://github.com/goodeggs/fibrous). Below is the example using both:

## Defining Factories

```coffeescript
# Basic models
userFactory = Unionized.define User, fibrous ->
  @username  ?= Faker.Helpers.replaceSymbolWithNumber("facebook-##########")
  @name      ?= "#{Faker.Name.firstName()} #{Faker.Name.lastName()}"
  @picture   ?= "http://www.gravatar.com/avatar/#{md5 Math.random().toString()}?d=identicon&f=y"
  @email     ?= Faker.Internet.email()
  @createdAt ?= new Date()

pageFactory = Unionized.define Page, fibrous ->
  @identifier   ?= Faker.Internet.slug()
  @url          ?= Faker.Internet.url()
  @createdAt    ?= new Date()
  @messageCount ?= 0

# Complex model. `mode` represents the way the factory is getting created, so we can create
# children in the same way if we desire
messageFactory = Unionized.define Message, fibrous (mode) ->
  @page       = pageFactory.sync[mode] @page unless @page instanceof Page
  @author     = userFactory.sync[mode] @author unless @author instanceof User
  @identifier ?= Faker.Internet.slug()
  @body       ?= Faker.Lorem.sentences(2)
  @createdAt  ?= new Date()

# Scenario example
pageWithCommentsFactory = Unionized.define fibrous (mode) ->
  @user1         = userFactory.sync[mode]()
  @user2         = userFactory.sync[mode]()
  @user3         = userFactory.sync[mode]()
  @page          = pageFactory.sync[mode]()
  @message_1     = messageFactory.sync[mode] {@page, author: @user1, createdAt: new Date('2013-03-03 10:00')}
  @message_1_1   = messageFactory.sync[mode] {@page, author: @user2, parent: @message_1}
  @message_1_1_1 = messageFactory.sync[mode] {@page, author: @user3, parent: @message_1_1}
  @message_1_2   = messageFactory.sync[mode] {@page, author: @user3, parent: @message_1}
  @message_2     = messageFactory.sync[mode] {@page, author: @user2, createdAt: new Date('2013-03-03 9:00')}
  @message_2_1   = messageFactory.sync[mode] {@page, author: @user3, parent: @message_2}

# Globally-defined factories by name
Unionized.define 'widget', fibrous ->
  @foo = 'bar'
```

## Using Factories

```coffeescript
# Basic syntax
console.log userFactory.sync.create()
#=> {username, name, picture, email, createdAt}

# Creating submodels
console.log messageFactory.sync.create page: {identifier, url}
#=> {page, author, identifier, body, createdAt}

# Using already created models
page = new Page attrs
console.log messageFactory.sync.create {page}
#=> {page, author, identifier, body, createdAt}

# Overwriting nested attributes
console.log pageWithCommentsFactory.sync.create {}, {'user1.name': 'Joe Bloggs', 'message_1_1_1.page.url': 'http://awesomesauce.com'}
#=> {...}

# Globally-defined factories
console.log Unionized.create 'widget'
#=> widget.foo 'bar'
```

### TODO: add non-fibrous examples

# License

The MIT License (MIT)

Copyright (c) 2013 Alex Gorbatchev and Max Edmands

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
