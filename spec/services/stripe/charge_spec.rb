describe Charge do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
  end
  after { StripeMock.stop }

  describe '.new' do
    it 'returns a new instance of Charge' do
      charge = Charge.new(customer_id: '1223345')
      expect(charge).to be_instance_of Charge
    end
  end

  describe '#call' do
    context 'when valid' do
      let(:customer) do
        Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          card: stripe_helper.generate_card_token
        })
      end
      subject(:charge) { Charge.new(customer_id: customer.id) }

      it 'charges a customer' do
        charge.call({})
        expect(charge.stripe_charge.customer).to eq(charge.customer_id)
      end

      it 'returns a Stripe::Charge' do
        stripe_charge = charge.call({})
        expect(stripe_charge).to be_instance_of Stripe::Charge
        expect(charge.stripe_charge).to be_instance_of Stripe::Charge
      end

      it 'has no errors' do
        charge.call({})
        expect(charge.errors.messages).to be_empty
      end
    end

    context 'when invalid' do
      let(:customer) do
        Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          card: stripe_helper.generate_card_token
          })
      end
      subject(:charge) { Charge.new(customer_id: nil) }

      before do
        StripeMock.prepare_card_error(:card_declined)
      end

      it 'has errors' do
        charge.call({})
        expect(charge.errors.messages).to_not be_empty
        expect(charge.errors.messages[:base].first).to eq('Your card was Declined!')
      end
    end
  end
end
