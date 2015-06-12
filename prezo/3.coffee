# Let me pare this down a bit...

describe 'payments', ->
  beforeEach ->
  buildCustomer = (attrs) ->
    _(
      object: "customer"
      discount: null
      delinquent: false
      subscription: null
      livemode: false
      created: 1338252831
      description: null
      account_balance: 0
      schedule: "postbill"
      id: "cus_1M7oD5WStQ3iGo"
      active_card:
        address_zip_check: null,
        type: "Visa",
        address_state: null,
        address_line1_check: null,
        exp_month: 4,
        address_zip: null,
        exp_year: 2013,
        address_line1: null,
        fingerprint: "tzLLKdDunxYxcujV",
        address_line2: null,
        name: null,
        country: "US",
        last4: "4779",
        cvc_check: "pass",
        object: "card",
        address_country: null
      email: 'somebody@example.com'
    ).extend(attrs)

  describe 'saveCreditCard', ->
    user = null

    beforeEach ->
      user = Factory.create 'user'
      user = User.sync.findById user

    describe 'non stripe customer', ->
      it 'creates a stripe customer with the cc', ->

        @sinon.stub(stripe.customers.sync, 'create').returns buildCustomer()

        tokenId = 'tok_u5dg20Gra'
        payments.sync.saveCreditCard(user, tokenId)

        expect(stripe.customers.sync.create).to.have.been.called
        request = stripe.customers.sync.create.lastCall.args[0]
        expect(request.card).to.eql tokenId
        expect(request.email).to.eql user.email
        expect(request.description).to.eql "#{user.name()}, #{user.id}"
        expect(request.metadata.userId).to.eql user.id

        user = User.sync.findById user

        expect(user.stripe.customer.id).to.eql 'cus_1M7oD5WStQ3iGo'
        expect(user.stripe.customer.active_card.fingerprint).to.eql 'tzLLKdDunxYxcujV'
        expect(user.stripe.customer.active_card.exp_month).to.eql 4
        expect(user.stripe.customer.active_card.exp_year).to.eql 2013
        expect(user.stripe.customer.active_card.last4).to.eql '4779'
        expect(user.stripe.customer.active_card.type).to.eql 'Visa'

    describe 'stripe customer', ->

      beforeEach ->
        user.stripe =
          customer:
            id: 'cus_1M7oD5WStQ3iGo'
            active_card:
              fingerprint: 'tzLLKdDunxYxcujV'
              exp_month: 4
              exp_year: 2013
              last4: '4779'
              type: 'Visa'
        user.markModified 'stripe'
        user.sync.save()
        user = User.sync.findById user
        expect(user.stripe.customer.id).to.be.ok

      it 'updates the existing stripe customer record', ->

        @sinon.stub(stripe.customers.sync, 'update').returns buildCustomer
          active_card:
            fingerprint: 'tzLLKdDunxYxcuiU'
            exp_month: 10
            exp_year: 2016
            last4: '4124'
            type: 'MasterCard'

        tokenId = 'tok_u5dg20Gra'
        payments.sync.saveCreditCard(user, tokenId)

        expect(stripe.customers.sync.update).to.have.been.called
        args = stripe.customers.sync.update.lastCall.args
        expect(args[0]).to.eql 'cus_1M7oD5WStQ3iGo'
        expect(args[1].card).to.eql tokenId

        user = User.sync.findById user

        expect(user.stripe.customer.id).to.eql 'cus_1M7oD5WStQ3iGo'
        expect(user.stripe.customer.active_card.fingerprint).to.eql 'tzLLKdDunxYxcuiU'
        expect(user.stripe.customer.active_card.token).to.eql 'tok_u5dg20Gra' # save the token so that we can avoid reuse
        expect(user.stripe.customer.active_card.exp_month).to.eql 10
        expect(user.stripe.customer.active_card.exp_year).to.eql 2016
        expect(user.stripe.customer.active_card.last4).to.eql '4124'
        expect(user.stripe.customer.active_card.type).to.eql 'MasterCard'
