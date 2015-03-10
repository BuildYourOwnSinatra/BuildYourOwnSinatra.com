describe RefundPurchase do
  describe '.new' do
    it 'returns a new instance of RefundPurchase' do
      expect(RefundPurchase.new(nil)).to be_instance_of RefundPurchase
    end
  end

  let(:env) do
    env = Rack::MockRequest.env_for('/purchases/bob/refund', {
      :method => :post,
      "rack.session" => {}
    })
    env['x-rack.flash'] ||= Rack::Flash::FlashHash.new(env['rack.session'], {accessorize: [:notice, :error] })
    env['eldr.request'] ||= Rack::Request.new(env)
    env['eldr.route'] = OpenStruct.new(name: nil)
    env
  end

  describe '#call' do
    context 'success' do
      before do
        allow_any_instance_of(Refund).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Refund).to receive(:valid?).and_return(true)
      end

      let(:purchase)        { FactoryGirl.create(:purchase) }
      let(:refund_purchase) { RefundPurchase.new(purchase) }
      let(:response)        { refund_purchase.call(env) }

      it 'sets purchase#refunded to true' do
        expect(purchase.refunded).to eq(false)

        refund_purchase.call(env)

        purchase.reload
        expect(purchase.refunded).to eq(true)
      end

      it 'sets purchase#id to the refunds id' do
        refund_purchase.call(env)

        purchase.reload
        expect(purchase.refund_id).to eq('cats-r-awesome')
      end

      it 'returns an HTML::Response' do
        expect(response).to be_instance_of Eldr::Responders::HTMLResponse
      end

      describe 'response' do
        it 'has a purchase object' do
          expect(response.object).to be_instance_of Purchase
        end

        it 'redirects to /purchases' do
          expect(response.headers['Location']).to eq('/purchases')
        end

        it 'has a message' do
          expect(response.message).to eq('Refunded Your Purchase')
        end
      end
    end

    context 'failure' do
      let(:stripe_helper) { StripeMock.create_test_helper }
      before { StripeMock.start }
      after { StripeMock.stop }
      before { StripeMock.prepare_card_error(:processing_error, :create_refund) }

      let(:charge) { Stripe::Charge.create(amount: 20, card: stripe_helper.generate_card_token) }

      let(:purchase)        { FactoryGirl.create(:purchase, charge_id: charge.id) }
      let(:refund_purchase) { RefundPurchase.new(purchase) }
      let(:response)        { refund_purchase.call(env) }

      it 'adds errors to #purchase' do
        refund_purchase.call(env)
        expect(refund_purchase.purchase.errors.messages).to_not be_empty
        expect(refund_purchase.purchase.errors.messages[:base].first).to eq('Your card was Declined!')
      end

      it 'sets flash error' do
        expect(response.env['x-rack.flash']['error']).to eq('Could not refund your purchase!! Contact support!')
      end

      it 'returns an HTML::Response' do
        expect(response).to be_instance_of Eldr::Responders::HTMLResponse
      end

      describe 'response' do
        it 'redirects to /purchases' do
          expect(response.headers['Location']).to eq('/purchases')
        end

        it 'has an error message' do
          expect(response.message).to eq('Could not refund your purchase!! Contact support!')
        end
      end
    end
  end
end
