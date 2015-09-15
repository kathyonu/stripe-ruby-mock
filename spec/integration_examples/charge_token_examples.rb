require 'spec_helper'
shared_examples 'Charging with Tokens' do
  describe 'With OAuth' do
    before do
      @cus = Stripe::Customer.create(
        source: stripe_helper.generate_card_token(last4: '4242')
      )
      @card_token = Stripe::Token.create({
        customer: @cus.id,
        source: @cus.sources.first.id
      }, ENV['STRIPE_TEST_OAUTH_ACCESS_TOKEN'])
    end

    it 'creates with an oauth access token', oauth: true do
      charge = Stripe::Charge.create({
        amount: 1099,
        currency: 'usd',
        source: @card_token.id
      }, ENV['STRIPE_TEST_OAUTH_ACCESS_TOKEN'])
      expect(charge.source.id).to_not eq @cus.sources.first.id
      expect(charge.source.last4).to eq '4242'

      retrieved_charge = Stripe::Charge.retrieve(charge.id)
      expect(retrieved_charge.source.id).to_not eq @cus.sources.first.id
      expect(retrieved_charge.source.last4).to eq '4242'
    end

    it 'throws an error when the card is not an id', oauth: true do
      expect {
        charge = Stripe::Charge.create({
          amount: 1099,
          currency: 'usd',
          source: @card_token
        }, ENV['STRIPE_TEST_OAUTH_ACCESS_TOKEN'])
      }.to raise_error(Stripe::InvalidRequestError, /Invalid token id/)
    end
  end
end
