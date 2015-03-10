describe CreateCustomer do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '.new' do
    it 'returns a new instance' do
      create_customer = CreateCustomer.new(email: 'bob@bob.com', stripe_token: 'token')
      expect(create_customer).to be_instance_of CreateCustomer
    end
  end

  describe '#call' do
    context 'when valid' do
      subject(:create_customer) { CreateCustomer.new(email: 'bob@bob.com', stripe_token: stripe_helper.generate_card_token) }

      it 'creates a customer' do
        create_customer.call({})
        expect(create_customer.id).to_not be_nil
        expect(create_customer.email).to eq('bob@bob.com')
      end

      it 'returns a Stripe::Customer' do
        expect(create_customer.call({})).to  be_instance_of Stripe::Customer
      end

      it 'has no errors' do
        create_customer.call({})
        expect(create_customer.errors.messages).to be_empty
      end
    end

    context 'when invalid' do
      subject(:create_customer) { CreateCustomer.new(email: 'bob@bob.com', stripe_token: stripe_helper.generate_card_token) }

      before { StripeMock.prepare_card_error(:missing, :new_customer) }

      it 'has errors' do
        create_customer.call({})
        expect(create_customer.errors.messages).to_not be_empty
        expect(create_customer.errors.messages[:base].first).to eq('Unable to process this purchase. Please email me: k@2052.me')
      end
    end
  end
end
