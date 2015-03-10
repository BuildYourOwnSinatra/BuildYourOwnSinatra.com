describe UpgradePurchase do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe '.new' do
    let(:purchase) { FactoryGirl.create(:purchase_with_user_and_package) }

    it 'returns a new instance of UpgradePurchase' do
      expect(UpgradePurchase.new(purchase: purchase, package_slug: purchase.package.slug)).to be_instance_of UpgradePurchase
    end
  end

  describe '#call' do
    let(:env) do
      env = Rack::MockRequest.env_for('/auth/github/callback', {
        :method => :post,
        "rack.session" => {}
      })
      env['x-rack.flash'] ||= Rack::Flash::FlashHash.new(env['rack.session'], {accessorize: [:notice, :error] })
      env['eldr.request'] ||= Rack::Request.new(env)
      env['eldr.route'] = OpenStruct.new(name: nil)
      env
    end

    context 'success' do
      before do
        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Charge).to receive(:valid?).and_return(true)
      end

      let(:purchase)         { FactoryGirl.create(:purchase_with_user_and_package) }
      let(:upgrade_package)  { FactoryGirl.create(:package, price: 120) }
      let(:upgrade_purchase) { UpgradePurchase.new(purchase: purchase, package_slug: purchase.package.slug) }
      let(:response)         { upgrade_purchase.call(env) }

      it 'sets purchase#upgraded to true' do
        expect(purchase.upgraded).to eq(false)

        upgrade_purchase.call(env)

        purchase.reload
        expect(purchase.upgraded).to eq(true)
      end

      it "sets purchase#charge_id to the charge's id" do
        upgrade_purchase.call(env)

        purchase.reload
        expect(purchase.charge_id).to eq('cats-r-awesome')
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
          expect(response.message).to eq("Upgraded you to: #{upgrade_package.name}")
        end
      end
    end

    context 'failure' do
      before do
        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
      end

      before { StripeMock.prepare_card_error(:processing_error, :new_charge) }

      let(:purchase)         { FactoryGirl.create(:purchase_with_user_and_package) }
      let(:upgrade_package)  { FactoryGirl.create(:package, price: 120) }
      let(:upgrade_purchase) { UpgradePurchase.new(purchase: purchase, package_slug: purchase.package.slug) }
      let(:response)         { upgrade_purchase.call(env) }

      it 'adds errors to purchase' do
        upgrade_purchase.call(env)
        expect(upgrade_purchase.purchase.errors.messages).to_not be_empty
        expect(upgrade_purchase.purchase.errors.messages[:base].first).to eq('Your card was Declined!')
      end

      it 'returns an HTML::Response' do
        expect(response).to be_instance_of Eldr::Responders::HTMLResponse
      end

      it 'sets flash error' do
        expect(response.env['x-rack.flash']['error']).to eq('Could not upgrade your purchase! Contact Me!')
      end

      describe 'response' do
        it 'redirects to /purchases' do
          expect(response.headers['Location']).to eq('/purchases')
        end

        it 'has an error message' do
          expect(response.message).to eq('Could not upgrade your purchase! Contact Me!')
        end
      end
    end
  end
end
