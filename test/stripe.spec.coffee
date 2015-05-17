expect = require('chai').expect
Promise = require 'bluebird'
unionized = require '..'

describe 'stripe tests', ->
  beforeEach ->
    @randomness = ->
      Math.random().toString(36).substr(2)

    @idFactory = (objType) ->
      => "#{objType}_#{@randomness()}"

    @cardFactory = unionized.factory
      id: @idFactory 'card'
      object: "card"
      last4: "4242"
      brand: "Visa"
      funding: "credit"
      exp_month: 1
      exp_year: 2018
      fingerprint: @randomness
      country: "US"
      name: null
      address_line1: null
      address_line2: null
      address_city: null
      address_state: null
      address_zip: null
      address_country: null
      cvc_check: "pass"
      address_line1_check: null
      address_zip_check: null
      dynamic_last4: null
      metadata: {}
      customer: @idFactory 'cus'
      type: "Visa"

    @chargeFactory = unionized.factory
      id: @idFactory 'ch'
      object: "charge"
      created: 1431644131
      livemode: false
      paid: true
      status: "paid"
      amount: 1999
      currency: "usd"
      refunded: false
      source: @cardFactory
      captured: true
      card: @cardFactory
      balance_transaction: @idFactory 'txn'
      failure_message: null
      failure_code: null
      amount_refunded: 0
      customer: @idFactory 'cus'
      invoice: null
      description: "Fulfillment of some sort"
      dispute: null
      metadata: {}
      statement_descriptor: "Good Eggs Inc."
      fraud_details: {}
      receipt_email: null
      receipt_number: null
      shipping: null
      application_fee: null
      refunds: []
      statement_description: "Good Eggs Inc."
      fee: 72
      fee_details: [
        amount: 72
        currency: "usd"
        type: "stripe_fee"
        description: "Stripe processing fees"
        application: null
        amount_refunded: 0
      ]
      uncaptured: null
      disputed: false

    @eventFactory = unionized.factory
      id: @idFactory 'evt'
      created: 1431644131
      livemode: false
      type: "charge.succeeded"
      "data.object": @chargeFactory
      object: "event"
      pending_webhooks: 1
      request: @idFactory 'iar'
      api_version: "2012-03-25"

  it 'can create stripe events including all the embedded objects', ->
    event = @eventFactory.create()
    expect(event).to.have.deep.property 'data.object.card.brand', 'Visa'

  it 'will create a new charge id every time the factory runs', ->
    chargeId1 = @eventFactory.create().data.object.id
    chargeId2 = @eventFactory.create().data.object.id
    expect(chargeId1).not.to.equal chargeId2

  it 'can create multiple fee details', ->
    feeDetails = @eventFactory.create('data.object.fee_details[]': 2).data.object.fee_details
    expect(feeDetails).to.have.length 2
