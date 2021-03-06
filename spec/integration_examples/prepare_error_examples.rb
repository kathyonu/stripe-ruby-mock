require 'spec_helper'

shared_examples 'Card Error Prep' do

  it 'prepares a card error' do
    StripeMock.prepare_card_error(:card_declined, :new_charge)
    cus = Stripe::Customer.create(email: 'alice@example.com')
    expect { Stripe::Charge.create(
      amount: 900,
      currency: 'usd',
      source: StripeMock.generate_card_token(number: '4242424242424241'),
      description: 'hello'
      )
    }.to raise_error(Stripe::CardError, 'The card was declined')
  end

  it 'is a valid card error', live: true do
    stripe_helper.prepare_card_error

    begin
    Stripe::Customer.create(
      email: 'alice@example.com',
      source: stripe_helper.generate_card_token(number: '123')
    )
    rescue Stripe::CardError => e
      body = e.json_body
      expect(body).to be_a(Hash)
      error = body[:error]

      expect(error[:type]).to eq 'card_error'
      expect(error[:param]).to eq 'number'
      expect(error[:code]).to eq 'invalid_number'
      expect(error[:message]).to eq 'The card number is not a valid credit card number.'
    end
  end
end
