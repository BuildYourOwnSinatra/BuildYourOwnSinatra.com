describe Refund do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '.new' do
    it 'returns a new instance' do
      expect(Refund.new(charge_id: '')).to be_instance_of Refund
    end
  end

  describe '#call' do
    context 'when valid' do
      subject(:refund_action) do
        charge = Stripe::Charge.create(amount: 20, card: stripe_helper.generate_card_token)
        Refund.new charge_id: charge.id
      end

      it 'refunds' do
        refund_action.call({})
        expect(refund_action.refund.id).to_not be_nil
        expect(refund_action.id).to_not be_nil
      end

      it 'returns Stripe::Refund' do
        stripe_refund = refund_action.call({})
        expect(stripe_refund).to be_instance_of Stripe::Refund
      end

      it 'has no errors' do
        refund_action.call({})
        expect(refund_action.errors.messages).to be_empty
      end
    end

    context 'when invalid' do
      subject(:refund_action) do
        charge = Stripe::Charge.create(amount: 20, card: stripe_helper.generate_card_token)
        Refund.new charge_id: charge.id
      end

      before { StripeMock.prepare_card_error(:processing_error, :create_refund) }

      it 'has errors' do
        refund_action.call({})
        expect(refund_action.errors.messages).to_not be_empty
        expect(refund_action.errors.messages[:base].first).to eq('Your card was Declined!')
      end
    end
  end
end
