# A TEST WITHOUT UNIONIZED
# cribbed from garbanzo
# src/orzo/spec/server/lib/payments/payments.spec.coffee

require 'orzo/spec_helpers/server'
payments = require 'orzo/server/lib/payments'
stripe = require 'orzo/server/lib/stripe'
{setFlatFlexPickupPrice} = require 'orzo/spec_helpers/foodshed_defaults'

{
  Basket
  GoodEggsPackaging,
  Fulfillment,
  SubscriptionItem,
  SubscriptionReorder,
  Vendor,
  Order,
  OrderItem,
  Refund,
  User,
  Checkout,
  FulfillmentEdit,
  Payment,
  PromoCode,
  Refund
} = require 'orzo/server/models'
{
  Transaction,
  UserStoreCreditAccount,
  UserStoreCreditAccountEntry
} = require 'orzo/server/models/accounting'

gePackagingFactory = require 'orzo/spec_helpers/factories/good_eggs_packaging.factory'
stripeErrors = require 'orzo/spec_helpers/stripe_errors'

describe 'payments', ->
  beforeEach ->
    @sinon.stub(clock, 'now') unless clock.now.returns
    clock.now.returns clock.pacific('2014-05-05 09:00')

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

  buildCharge = (amount, description) ->
      amount: amount
      refunded: false
      object: "charge"
      fee: 0
      failure_message: null
      amount_refunded: 0
      disputed: false
      currency: "usd"
      livemode: false
      customer: null
      created: 1338252831
      paid: true
      invoice: null
      description: description
      id: "ch_MagSTwHGyyNn7h"
      card:
        address_line1_check: null
        type: "Visa"
        exp_month: 8
        last4: "4242"
        object: "card"
        address_zip: null
        exp_year: 2013
        address_line1: null
        country: "US"
        address_line2: null
        cvc_check: null
        address_country: null
        name: null
        address_zip_check: null
        address_state: null
        fingerprint: "tzLLKdDunxYxcujV"

  describe '.captureOrCharge', ->
    {user, fulfillment, checkout, action, refund, charge} = {}

    beforeEach ->
      user = Factory.create 'user', stripe: Factory.create 'userStripeDoc'
      @sinon.stub(stripe.charges.sync, 'capture')
      @sinon.stub(stripe.charges.sync, 'create')
      @sinon.stub(stripe.charges.sync, 'refund').returns({id: 'chargeId', amount_refunded: 10})

    describe 'an existing auth', ->
      {createCheckout, createCheckoutParams} = {}

      beforeEach ->
        createCheckoutParams =
          stripeAmountRefunded: undefined

        createCheckout = ({stripeAmountRefunded}) ->
          fulfillment = Factory.create 'fulfillment', stripe: auth: {id: 'authId', amount: 10, amountRefunded: stripeAmountRefunded}
          checkout = Checkout.sync.buildFromFulfillment(fulfillment)
          checkout.sync.save()

      describe 'when amount is lower than authed', ->
        beforeEach ->
          createCheckout(createCheckoutParams)
          charge = payments.sync.captureOrCharge(checkout, user, 5, 'description')

        it 'sets capture action', ->
          expect(checkout.stripe.action).to.equal 'capture'

        it 'does not create any new charges', ->
          expect(stripe.charges.sync.create).not.to.have.been.called

        it 'captures the auth', ->
          expect(stripe.charges.sync.capture).to.have.been.called

        it 'captures the correct amount', ->
          args = stripe.charges.sync.capture.lastCall.args
          expect(args[1].amount).to.eql 500

        it 'uses the uncaptured charge', ->
          args = stripe.charges.sync.capture.lastCall.args
          expect(args[0]).to.eql fulfillment.stripe.auth.id

      describe 'when amount is higher than authed', ->
        beforeEach ->
          createCheckout(createCheckoutParams)
          charge = payments.sync.captureOrCharge(checkout, user, 15.50, 'description')

        it 'sets refund_and_charge action', ->
          expect(checkout.stripe.action).to.equal 'refund_and_charge'

        it 'does not capture any charges', ->
          expect(stripe.charges.sync.capture).not.to.have.been.called

        it 'refunds the auth', ->
          expect(stripe.charges.sync.refund).to.have.been.called

        it 'refunds the amount authed', ->
          args = stripe.charges.sync.refund.lastCall.args
          expect(args[0]).to.equal fulfillment.stripe.auth.id
          expect(args[1].amount).to.eql 1000

        it 'creates a new charge', ->
          expect(stripe.charges.sync.create).to.have.been.called

        it 'charges the full amount', ->
          args = stripe.charges.sync.create.lastCall.args
          expect(args[0].customer).to.equal user.stripe.customer.id
          expect(args[0].amount).to.eql 1550

        it 'takes metadata from the checkout', ->
          args = stripe.charges.sync.create.lastCall.args
          expect(args[0].metadata).to.have.property 'fulfillmentId', fulfillment.id

      describe 'with a stripeAmountRefunded', ->
        beforeEach ->
          createCheckoutParams.stripeAmountRefunded = 1
          createCheckout(createCheckoutParams)
          charge = payments.sync.captureOrCharge(checkout, user, 15.50, 'description')

        it 'does not call refund', ->
          expect(stripe.charges.sync.refund).not.to.have.been.called

      describe 'when stripe throws temporary error', ->
        beforeEach ->
          stripe.charges.sync.create.throws stripeErrors.goodEggs.processingError
          createCheckout(createCheckoutParams)
          try
            charge = payments.sync.captureOrCharge(checkout, user, 15.50, 'description')
          catch

        it 'sets the amountRefunded on the checkout stripe auth', ->
          checkout = Checkout.sync.findById checkout.id
          expect(checkout.stripe.auth.amountRefunded).to.equal 0.10

        it 'sets the amountRefunded on the fulfillment stripe auth', ->
          fulfillment = Fulfillment.sync.findById fulfillment.id
          expect(fulfillment.stripe.auth.amountRefunded).to.equal 0.10

    describe 'no existing auth', ->
      beforeEach ->
        fulfillment = Factory.create 'fulfillment', stripe: {}
        checkout = Checkout.sync.buildFromFulfillment(fulfillment)

        charge = payments.sync.captureOrCharge(checkout, user, 10, 'description')

      it 'sets charge action', ->
        expect(checkout.stripe.action).to.equal 'charge'

      it 'creates a new charge with metadata from the checkout', ->
        expect(stripe.charges.sync.create).to.have.been.called
        args = stripe.charges.sync.create.lastCall.args
        expect(args[0].metadata).to.have.property 'fulfillmentId', fulfillment.id

      it 'does not refund anything', ->
        expect(stripe.charges.sync.capture).not.to.have.been.called

    describe 'an expired auth', ->
      beforeEach ->
        fulfillment =
          Factory.create 'fulfillment',
            stripe:
              auth:
                id: 'ch_987236nojf9'
                createdAt: new Date clock.now() - 8.days()
                amount: 1000

        checkout = Checkout.sync.buildFromFulfillment(fulfillment)

        charge = payments.sync.captureOrCharge(checkout, user, 10, 'description')

      it 'sets charge action', ->
        expect(checkout.stripe.action).to.equal 'charge'

      it 'creates a new charge', ->
        expect(stripe.charges.sync.create).to.have.been.called

      it 'does not refund anything', ->
        expect(stripe.charges.sync.capture).not.to.have.been.called

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

      it 'does nothing if the token was already used', ->
        tokenId = 'tok_u5dg20Gra'
        user.stripe.customer.active_card.token = tokenId
        user.markModified 'stripe'
        user.sync.save()

        @sinon.stub(stripe.customers.sync, 'update')

        payments.sync.saveCreditCard(user, tokenId)
        expect(stripe.customers.sync.update).not.to.have.been.called

  describe '#pay', ->
    {user, vendor, postPaymentSpy} = {}
    stripeChargeId = 'ch_MagSTwHGyyNn7h'

    beforeEach ->
      postPaymentSpy = @sinon.stub Transaction, 'postPayment',  (payable, {args}, cb) -> cb(null, {_id: 'transactionId'})
      vendor = Factory.create 'vendor'
      user = Factory.create 'user',
        stripe: Factory.create 'userStripeDoc'

    describe 'a digital GiftCard is being purchased', ->
      {giftCard} = {}

      beforeEach ->
        giftCard = Factory.create 'giftCard'
        @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))
        payments.sync.pay(giftCard, user)

      it 'charges stripe for the gift card amount', ->
        expect(stripe.charges.create).to.have.been.called
        request = stripe.charges.create.lastCall.args[0]
        expect(request.amount).to.eql giftCard.amount * 100

      it 'posts the payment', ->
        expect(Transaction.postPayment).to.have.been.called

      it 'marks the giftcard as paid', ->
        expect(giftCard.status).to.equal 'paid'

      it 'records payment details', ->
        payment = giftCard.payments[0]
        expect(payment.source).to.equal 'stripe'
        # expect(payment.amount).to.equal giftCard.billingTotal()
        expect(payment.data.id).to.equal stripeChargeId
        expect(giftCard.payments.length).to.equal 1

    describe 'for a checkout built from a fulfillment', ->
      {checkout, fulfillment} = {}

      beforeEach ->
        {fulfillment} = Factory.create 'orderForDelivery'
        setFlatFlexPickupPrice('sfbay', 5)
        checkout = Checkout.sync.buildFromFulfillment fulfillment
        checkout.sync.save()

        @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))

      describe 'that does not have an auth', ->
        beforeEach ->
          payments.sync.pay(checkout, user)
          checkout = Checkout.sync.findById checkout

        it 'includes the fulfillments billing description', ->
          expect(stripe.charges.create).to.have.been.called
          request = stripe.charges.create.lastCall.args[0]
          expect(request.description).to.contain fulfillment.billingDescription()

        it 'charges for all the orders with one stripe transaction', ->
          expect(stripe.charges.create).to.have.been.called
          request = stripe.charges.create.lastCall.args[0]
          # expect(request.amount).to.eql checkout.billingTotal() * 100 # cents

        it 'update checkout.stripe', ->
          expect(checkout.stripe.action).to.equal 'charge'
          expect(checkout.stripe.charge).to.be.defined
          expect(checkout.stripe.auth.id).not.to.be.defined

        it 'accounts for the checkout', ->
          expect(Transaction.postPayment).to.have.been.called
          expect(Transaction.postPayment.callCount).to.equal 1

        it 'marks all orders paid', ->
          checkout.sync.populate('orders')
          expect(_.all checkout.orders, (o) -> o.status is 'paid').to.be.ok

        it 'records payment details', ->
          payment = checkout.payments[0]
          expect(payment.source).to.equal 'stripe'
          # expect(payment.amount).to.equal checkout.billingTotal()
          expect(payment.data.id).to.equal stripeChargeId
          expect(payment.data.card.last4).to.equal '4242'
          expect(payment.data.card.type).to.equal 'Visa'
          expect(checkout.payments.length).to.equal 1

      describe 'that has an auth less than the charge amount', ->
        beforeEach ->
          checkout.stripe.auth = {id: 'authId', amount: 1}
          @sinon.stub(stripe.charges.sync, 'refund').returns({id: 'authId', amount_refunded: 1000})
          payments.sync.pay(checkout, user)
          checkout = Checkout.sync.findById checkout

        it 'update checkout.stripe', ->
          expect(checkout.stripe.action).to.equal 'refund_and_charge'
          expect(checkout.stripe.charge.id).to.be.defined
          expect(checkout.stripe.auth.amountRefunded).to.equal 10

      describe 'that has an auth more than the charge amount', ->
        beforeEach ->
          checkout.stripe.auth = {id: 'authId', amount: 10}
          @sinon.stub(stripe.charges.sync, 'capture').returns {id: 'captureId'}
          payments.sync.pay(checkout, user)
          checkout = Checkout.sync.findById checkout

        it 'update checkout.stripe', ->
          expect(checkout.stripe.action).to.equal 'capture'
          expect(checkout.stripe.charge.id).to.be.defined
          expect(checkout.stripe.auth.refund).not.to.be.defined

      describe 'the user has enough store credit to pay for the fulfillment and an auth', ->
        beforeEach ->
          userStoreCreditAccount = UserStoreCreditAccount.sync.create
            user: user
            balance: 1000
          checkout.stripe.auth = {id: 'authId', amount: 5}
          @sinon.stub(stripe.charges.sync, 'capture').returns {id: 'captureId'}
          @sinon.stub(stripe.charges.sync, 'create').returns {id: 'captureId'}
          @sinon.stub(stripe.charges.sync, 'refund').returns {id: 'captureId', amount_refunded: 500}
          payments.sync.pay(checkout, user, userStoreCreditAccount)
          checkout = Checkout.sync.findById checkout

        it 'records the amount refunded on the checkout', ->
          expect(checkout.stripe.auth.amountRefunded).to.eql 5

        it 'records that the auth was refunded', ->
          expect(checkout.stripe.action).to.eql 'auth_refunded'

        it 'refunds the auth', ->
          expect(stripe.charges.sync.refund).to.have.been.called
          call = stripe.charges.sync.refund.lastCall
          expect(call.args[0]).to.eql 'authId'
          expect(call.args[1].amount).to.eql 500

        it 'does not call capture', ->
          expect(stripe.charges.sync.capture).not.to.have.been.called

        it 'does not call charge', ->
          expect(stripe.charges.sync.create).not.to.have.been.called

      describe 'the user has an auth and less store credit than the total on the fulfillment', ->
        beforeEach ->
          userStoreCreditAccount = UserStoreCreditAccount.sync.create
            user: user
            balance: 1
          checkout.stripe.auth = {id: 'authId', amount: 50}
          @sinon.stub(stripe.charges.sync, 'capture').returns {id: 'captureId'}
          @sinon.stub(stripe.charges.sync, 'create').returns {id: 'createId'}
          @sinon.stub(stripe.charges.sync, 'refund').returns {id: 'refundId'}
          payments.sync.pay(checkout, user, userStoreCreditAccount)
          checkout = Checkout.sync.findById checkout

        it 'calls capture with the remaining balance after using the credit', ->
          expect(stripe.charges.sync.capture).to.have.been.called
          call = stripe.charges.sync.capture.lastCall
          expect(call.args[0]).to.eql 'authId'
          expect(call.args[1].amount).to.eql 799

        it 'records that we captured the charge', ->
          expect(checkout.stripe.action).to.eql 'capture'

        it 'records the capture id as the charge id', ->
          expect(checkout.stripe.charge.id).to.eql 'captureId'

        it 'does not call charge', ->
          expect(stripe.charges.sync.create).not.to.have.been.called

        it 'does not call refund', ->
          expect(stripe.charges.sync.refund).not.to.have.been.called

    describe 'for a checkout with an absolute promo code', ->
      {promoCode, checkout} = {}

      describe 'that partially covers the cost of the checkout', ->
        beforeEach ->
          {fulfillment} = Factory.create 'orderForDelivery'
          setFlatFlexPickupPrice('sfbay', 5)
          promoCode = Factory.create 'promoCode'
          fulfillment.promoCodes.push promoCode
          checkout = Checkout.sync.buildFromFulfillment fulfillment

          @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))
          payments.sync.pay(checkout, user)

        it 'has recorded the discounted amount as a payment', ->
          payment = _(checkout.payments).findWhere source: 'goodEggsPromo'
          expect(payment.data.id).to.equal 'transactionId'
          expect(payment.amount).to.equal promoCode.value

        it 'has recorded the amount charged on the credit card as a payment', ->
          payment = _(checkout.payments).findWhere source: 'stripe'
          expect(payment.amount).to.equal checkout.billingTotal()
          expect(payment.data.id).to.equal stripeChargeId

        it 'records 2 payments', ->
          expect(checkout.payments.length).to.equal 2

      describe 'that fully covers the cost of the checkout', ->

        beforeEach ->
          promoCode = Factory.create 'promoCode',
            type: 'dollar'
            value: 100

          {fulfillment} = Factory.create 'orderForDelivery'
          setFlatFlexPickupPrice('sfbay', 5)
          fulfillment.promoCodes.push promoCode
          checkout = Checkout.sync.buildFromFulfillment fulfillment

          payments.sync.pay(checkout, user)

        it 'has recorded the discounted amount as a payment', ->
          payment = _(checkout.payments).findWhere source: 'goodEggsPromo'
          expect(payment.data.id).to.equal 'transactionId'
          expect(payment.amount).to.equal 8.99

        it 'has recorded the amount charged on the credit card as a payment', ->
          payment = _(checkout.payments).findWhere source: 'stripe'
          expect(payment).not.to.be.ok

        it 'records 1 payments', ->
          expect(checkout.payments.length).to.equal 1

    describe 'for a checkout with a percentage promo code', ->
      {promoCode, checkout, expectedDiscount} = {}

      beforeEach ->
        promoCode = Factory.create 'promoCode',
          type: 'percent'
          value: 10

        {fulfillment} = Factory.create 'orderForDelivery'
        setFlatFlexPickupPrice('sfbay', 5)
        fulfillment.promoCodes.push promoCode
        checkout = Checkout.sync.buildFromFulfillment fulfillment

        @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))
        payments.sync.pay(checkout, user)

      it 'has recorded the discounted amount as a payment', ->
        payment = _(checkout.payments).findWhere source: 'goodEggsPromo'
        expect(payment.amount).to.equal 0.9
        expect(payment.data.id).to.equal 'transactionId'

      it 'has recorded the amount charged on the credit card as a payment', ->
        payment = _(checkout.payments).findWhere source: 'stripe'
        expect(payment.amount).to.equal checkout.billingTotal()
        expect(payment.data.id).to.equal stripeChargeId

      it 'records 2 payments', ->
        expect(checkout.payments.length).to.equal 2

    describe 'for a checkout with store credit and a percentage promo code', ->
      {promoCode, checkout, expectedDiscount, userStoreCreditAccount} = {}

      beforeEach ->
        userStoreCreditAccount = UserStoreCreditAccount.sync.findOrCreate user: user
        transaction = new Transaction type: 'credit.gift_card'
        entry = UserStoreCreditAccountEntry.sync.create { userStoreCreditAccount, transaction, amount: 5 }
        fibrous.sync.waitForLoggedFutures()
        userStoreCreditAccount = UserStoreCreditAccount.sync.findOne user: user
        expect(userStoreCreditAccount.balance).to.equal 5

        promoCode = Factory.create 'promoCode',
          type: 'percent'
          value: 10

        {fulfillment} = Factory.create 'orderForDelivery'
        setFlatFlexPickupPrice('sfbay', 5)
        fulfillment.promoCodes.push promoCode
        checkout = Checkout.sync.buildFromFulfillment fulfillment

        @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))
        payments.sync.pay(checkout, user, userStoreCreditAccount)

      it 'has recorded the discounted amount as a payment', ->
        payment = _(checkout.payments).findWhere source: 'goodEggsPromo'
        expect(payment.amount).to.equal 0.9
        expect(payment.data.id).to.equal 'transactionId'

      it 'has recorded the amount charged on the credit card as a payment', ->
        payment = _(checkout.payments).findWhere source: 'stripe'
        expect(payment.amount).to.equal checkout.billingTotal() - 5
        expect(payment.data.id).to.equal stripeChargeId

      it 'has recorded the amount charged to store credit as a payment', ->
        payment = _(checkout.payments).findWhere source: 'userStoreCredit'
        expect(payment.amount).to.equal 5
        expect(payment.data.id).to.equal 'transactionId'

      it 'records 3 payments', ->
        expect(checkout.payments.length).to.equal 3

      it 'calls stripe with the remaining balance', ->
        expect(stripe.charges.create).to.have.been.called
        request = stripe.charges.create.lastCall.args[0]
        expect(request.amount).to.eql checkout.total * 100 - 500

      it 'marks all orders paid', ->
        checkout.sync.populate('orders')
        expect(_.all checkout.orders, (o) -> o.status is 'paid').to.be.ok

      it 'debits the users store credit account', ->
        args = Transaction.postPayment.lastCall.args[1]
        expect(args.userCreditAmount).to.equal 5

    describe 'for a checkout with store credit', ->
      {checkout, userStoreCreditAccount} = {}
      beforeEach ->
        userStoreCreditAccount = UserStoreCreditAccount.sync.findOrCreate user: user

        {fulfillment} = Factory.create 'orderForDelivery'
        setFlatFlexPickupPrice('sfbay', 5)
        checkout = Checkout.sync.buildFromFulfillment fulfillment

      describe 'that covers the full cost', ->
        beforeEach ->
          transaction = new Transaction type: 'credit.gift_card'
          entry = UserStoreCreditAccountEntry.sync.create { userStoreCreditAccount, transaction, amount: 500 }
          fibrous.sync.waitForLoggedFutures()
          userStoreCreditAccount = UserStoreCreditAccount.sync.findOrCreate user: user
          expect(userStoreCreditAccount.balance).to.equal 500

          @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb("this should never happen!")
          payments.sync.pay(checkout, user, userStoreCreditAccount)

        it 'does not call stripe', ->
          expect(stripe.charges.create).not.to.have.been.called

        it 'marks all orders paid', ->
          checkout.sync.populate('orders')
          expect(_.all checkout.orders, (o) -> o.status is 'paid').to.be.ok

        it 'records payment details', ->
          payment = checkout.payments[0]
          expect(payment.source).to.equal 'userStoreCredit'
          expect(payment.amount).to.equal checkout.billingTotal()
          expect(payment.data.id).to.equal 'transactionId'
          expect(checkout.payments.length).to.equal 1

        it 'debits the users store credit account', ->
          expectedArgs =
            chargeData: undefined
            promoCodeDiscount: 0
            userCreditAmount: checkout.billingTotal()
          expect(postPaymentSpy.lastCall.args[0]).to.eql checkout
          expect(postPaymentSpy.lastCall.args[1]).to.eql expectedArgs

      describe 'that does not covers the full cost', ->
        beforeEach ->
          transaction = new Transaction type: 'credit.gift_card'
          entry = UserStoreCreditAccountEntry.sync.create { userStoreCreditAccount, transaction, amount: 5 }
          fibrous.sync.waitForLoggedFutures()
          userStoreCreditAccount = UserStoreCreditAccount.sync.findOne user: user
          expect(userStoreCreditAccount.balance).to.equal 5

          @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))
          payments.sync.pay(checkout, user, userStoreCreditAccount)

        it 'calls stripe with the remaining balance', ->
          expect(stripe.charges.create).to.have.been.called
          request = stripe.charges.create.lastCall.args[0]
          expect(request.amount).to.eql checkout.total * 100 - 500

        it 'marks all orders paid', ->
          checkout.sync.populate('orders')
          expect(_.all checkout.orders, (o) -> o.status is 'paid').to.be.ok

        it 'records payment details', ->
          expect(checkout.payments.length).to.equal 2
          for payment in checkout.payments
            if payment.source is 'stripe'
              expect(payment.amount).to.equal checkout.billingTotal() - 5
              expect(payment.data.id).to.equal stripeChargeId
            else
              expect(payment.source).to.equal 'userStoreCredit'
              expect(payment.amount).to.equal 5
              expect(payment.data.id).to.equal 'transactionId'

        it 'debits the users store credit account', ->
          args = Transaction.postPayment.lastCall.args[1]
          expect(args.userCreditAmount).to.equal 5

    describe 'for overdue good eggs packaging', ->
      {packaging} = {}

      describe 'credit card success', ->
        beforeEach ->
          packaging = gePackagingFactory.sync.create {user}
          @sinon.stub stripe.charges, 'create',  ({amount}, cb) -> cb(null, buildCharge(amount, ''))
          payments.sync.pay(packaging, user)

        it 'charges stripe for the packaging amount', ->
          expect(stripe.charges.create).to.have.been.called
          request = stripe.charges.create.lastCall.args[0]
          expect(request.amount).to.eql packaging.amount * 100

        it 'posts the payment', ->
          expect(Transaction.postPayment).to.have.been.called

        it 'marks the packaging as paid', ->
          expect(packaging.status).to.equal 'paid'

        it 'records payment details', ->
          payment = packaging.payments[0]
          expect(payment.source).to.equal 'stripe'
          expect(payment.amount).to.equal packaging.amount
          expect(payment.data.id).to.equal stripeChargeId
          expect(packaging.payments.length).to.equal 1

  describe 'auth & charge', ->
    {user, captureArgs} = {}

    beforeEach ->
      user = Factory.create 'user',
        stripe: Factory.create 'userStripeDoc'

      @sinon.stub stripe.charges, 'create',  (options, cb) ->
        captureArgs = options
        cb(null, buildCharge(options.amount, ''))

    describe 'calling .auth', ->
      {thrownError, attemptAuth} = {}
      beforeEach ->
        attemptAuth = (authAmount, metadata) ->
          try
            payments.sync.auth user, authAmount, 'we charged for something', metadata
          catch thrownError

      it 'should pass capture: false in the call to stripe', ->
        attemptAuth(3.15)
        expect(captureArgs.capture).to.eql false

      it 'should pass metadata in the call to stripe', ->
        attemptAuth(3.15, foo: 'bar')
        expect(captureArgs.metadata.foo).to.eql 'bar'

      it 'should not pass empty metadata in the call to stripe', ->
        attemptAuth(3.15)
        expect(captureArgs.metadata).to.not.be.defined

      describe 'authing with 0', ->
        beforeEach ->
          attemptAuth(0)

        it 'should not call charge', ->
          expect(stripe.charges.create).not.to.have.been.called

        it 'should raise a 402 error', ->
          expect(thrownError.statusCode).to.equal 402

    describe 'calling .charge', ->
      it 'should pass capture: true in the call to stripe', ->
        payments.sync.charge user, 3.15, 'we charged for something'
        expect(captureArgs.capture).to.eql true

      it 'should pass metadata in the call to stripe', ->
        payments.sync.charge user, 3.15, 'we charged for something', {foo: 'bar'}
        expect(captureArgs.metadata.foo).to.eql 'bar'

      it 'should not pass empty metadata in the call to stripe', ->
        payments.sync.charge user, 3.15, 'we charged for something'
        expect(captureArgs.metadata).to.not.be.defined
