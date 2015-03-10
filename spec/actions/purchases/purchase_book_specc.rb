describe PurchaseBook do
  describe '.new' do
    it 'returns a new instance of PurchaseBook' do
      purchase_book_action = PurchaseBook.new(      package: FactoryGirl.create(:package),
                                                       user: FactoryGirl.create(:user),
                                               stripe_token: 'tokeny')
      expect(purchase_book_action).to be_instance_of PurchaseBook
    end
  end

  describe 'call' do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:env) do
      env = Rack::MockRequest.env_for('/purchases', {
        :method => :post,
        "rack.session" => {}
      })
      env['x-rack.flash'] ||= Rack::Flash::FlashHash.new(env['rack.session'], {accessorize: [:notice, :error] })
      env['eldr.request'] ||= Rack::Request.new(env)
      env['eldr.route'] = OpenStruct.new(name: nil)
      env
    end

    context 'when all data is valid' do
      before do
        allow_any_instance_of(CreateCustomer).to receive(:valid?).and_return(true)
        allow_any_instance_of(CreateCustomer).to receive(:id).and_return('customer_id')

        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Charge).to receive(:valid?).and_return(true)

        allow_any_instance_of(AddTeamMembership).to receive(:valid?).and_return(true)
      end

      let(:purchase_book_action) do
        PurchaseBook.new(      package: FactoryGirl.create(:package),
                                  user: FactoryGirl.create(:user),
                          stripe_token: 'tokeny')
      end

      let(:response) { purchase_book_action.call(env) }

      it 'sets userstripe_id' do
        purchase_book_action.call(env)
        expect(purchase_book_action.user.stripe_id).to eq('customer_id')
      end

      it 'sets purchasecharge_id' do
        purchase_book_action.call(env)
        expect(purchase_book_action.purchase.charge_id).to eq('cats-r-awesome')
      end

      it 'sets purchase price' do
        expect(purchase_book_action.purchase.price).to be_nil
        purchase_book_action.call(env)
        expect(purchase_book_action.purchase.price).to eq(20)
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
          expect(response.message).to eq('Book Purchased!')
        end
      end
    end

    context 'when Stripe cant create a customer' do
      before do
        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Charge).to receive(:valid?).and_return(true)

        allow_any_instance_of(AddTeamMembership).to receive(:valid?).and_return(true)
      end

      before { StripeMock.prepare_card_error(:processing_error, :create_customer) }

      let(:purchase_book_action) do
        PurchaseBook.new(      package: FactoryGirl.create(:package),
                                  user: FactoryGirl.create(:user),
                          stripe_token: 'tokeny')
      end

      let(:response) { purchase_book_action.call(env) }

      it 'adds errors to purchase' do
        purchase_book_action.call(env)

        expect(purchase_book_action.purchase.errors.messages[:base].first).to eq('Unable to process this purchase. Please email me: k@2052.me')
      end

      it 'sets flash error' do
        expect(response.env['x-rack.flash']['error']).to eq('Could not create customer at Stripe! Contact Support!')
      end

      it 'returns an HTML::Response' do
        expect(response).to be_instance_of Eldr::Responders::HTMLResponse
      end

      describe 'response' do
        it 'redirects to /#buy' do
          expect(response.headers['Location']).to eq('/#buy')
        end

        it 'has an error message' do
          expect(response.message).to eq('Could not create customer at Stripe! Contact Support!')
        end
      end
    end

    context 'when charge does not go through' do
      before do
        allow_any_instance_of(CreateCustomer).to receive(:valid?).and_return(true)
        allow_any_instance_of(CreateCustomer).to receive(:id).and_return('customer_id')

        allow_any_instance_of(AddTeamMembership).to receive(:valid?).and_return(true)
      end

      before { StripeMock.prepare_card_error(:processing_error, :new_charge) }

      let(:purchase_book_action) do
        PurchaseBook.new(     package: FactoryGirl.create(:package),
                                 user: FactoryGirl.create(:user),
                         stripe_token: 'tokeny')
      end

      let(:response) { purchase_book_action.call(env) }

      it 'adds errors to purchase' do
        purchase_book_action.call(env)
        expect(purchase_book_action.purchase.errors.messages[:base].first).to eq('Your card was Declined!')
      end

      it 'sets flash error' do
        expect(response.env['x-rack.flash']['error']).to eq('Could not charge you! Contact Support!')
      end

      it 'returns an HTML::Response' do
        expect(response).to be_instance_of Eldr::Responders::HTMLResponse
      end

      describe 'response' do
        it 'redirects to /#buy' do
          expect(response.headers['Location']).to eq('/#buy')
        end

        it 'has an error message' do
          expect(response.message).to eq('Could not charge you! Contact Support!')
        end
      end
    end

    context 'when AddTeamMembership does not go through' do
      before do
        allow_any_instance_of(CreateCustomer).to receive(:valid?).and_return(true)
        allow_any_instance_of(CreateCustomer).to receive(:id).and_return('customer_id')

        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Charge).to receive(:valid?).and_return(true)
      end

      let(:purchase_book_action) do
        PurchaseBook.new(package: FactoryGirl.create(:package),
                            user: FactoryGirl.create(:user),
                    stripe_token: 'tokeny')
      end

      let(:response) { purchase_book_action.call(env) }

      it 'adds errors to purchase' do
        purchase_book_action.call(env)
        expect(purchase_book_action.purchase.errors.messages[:base].first).to eq('Could not give you read permisions to GitHub repos. Please contact k@2052.me')
      end

      it 'sets flash error' do
        expect(response.env['x-rack.flash']['error']).to eq('Could not add you to the GitHub repo! Contact me!')
      end

      it 'returns an HTML::Response' do
        expect(response).to be_instance_of Eldr::Responders::HTMLResponse
      end

      describe 'response' do
        it 'redirects to /purchases' do
          expect(response.headers['Location']).to eq('/purchases')
        end

        it 'has an error message' do
          expect(response.message).to eq('Could not add you to the GitHub repo! Contact me!')
        end
      end
    end
  end
end
