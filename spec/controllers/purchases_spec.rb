describe Purchases do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe 'GET /purchases' do
    context 'when authorized' do
      let(:user) { FactoryGirl.create(:user_with_purchases) }

      it 'renders a purchases page' do
        get '/purchases', nil, {'rack.session' => { "#{ENV['SESSION_ID']}" => user.id }}
        expect(last_response.status).to eq(200)
      end
    end

    context 'when NOT authorized' do
      it 'returns not authorized' do
        get '/purchases'
        expect(last_response.status).to eq(401)
      end
    end
  end

  describe 'POST /purchases' do
    context 'when logged in an data is valid' do
      before do
        allow_any_instance_of(CreateCustomer).to receive(:valid?).and_return(true)
        allow_any_instance_of(CreateCustomer).to receive(:id).and_return('customer_id')

        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Charge).to receive(:valid?).and_return(true)

        allow_any_instance_of(AddTeamMembership).to receive(:call).and_return(true)
        allow_any_instance_of(AddTeamMembership).to receive(:valid?).and_return(true)
      end

      let(:env)     { {'rack.session' => {"#{ENV['SESSION_ID']}" => user.id}} }
      let(:user)    { FactoryGirl.create(:user) }
      let(:package) { FactoryGirl.create(:package) }

      it 'redirects to purchases' do
        post '/purchases', {package: package.slug, stripeToken: 'bob'}, env
        expect(last_response.status).to eq(303)
        expect(last_response.headers['Location']).to eq(ENV['READ_URL'])
      end
    end

    context 'when NOT authorized' do
      it 'returns not authorized' do
        post '/purchases'
        expect(last_response.status).to eq(401)
      end
    end
  end

  describe 'PUT /purchases/:id/upgrade' do
    let(:purchase)        { FactoryGirl.create(:purchase_with_user_and_package) }
    let(:user)            { purchase.user }
    let(:upgrade_package) { FactoryGirl.create(:package, price: 120) }

    context 'when data is valid' do
      before do
        allow_any_instance_of(Charge).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Charge).to receive(:valid?).and_return(true)
      end

      let(:env) { {'rack.session' => {"#{ENV['SESSION_ID']}" => user.id}} }

      it 'redirects back to purchases' do
        put "/purchases/#{purchase.id}/upgrade", {package: upgrade_package.slug}, env
        expect(last_response.status).to eq(303)
        expect(last_response.headers['Location']).to eq('/purchases')
      end
    end

    it 'upgrades a purchase' do
    end
  end

  describe 'PUT /purchases/:id/refund' do
    let(:user) { FactoryGirl.create(:user_with_purchases) }
    let(:purchase) { user.purchases.first }

    context 'when data is valid' do
      before do
        allow_any_instance_of(Refund).to receive(:id).and_return('cats-r-awesome')
        allow_any_instance_of(Refund).to receive(:valid?).and_return(true)
      end

      let(:env) { {'rack.session' => {"#{ENV['SESSION_ID']}" => user.id}} }

      it 'redirects back to purchases' do
        put "/purchases/#{purchase.id}/refund", nil, env
        expect(last_response.status).to eq(303)
        expect(last_response.headers['Location']).to eq('/purchases')
      end
    end

    context 'when NOT authorized' do
      it 'returns not authorized' do
        put "/purchases/#{purchase.id}/refund"
        expect(last_response.status).to eq(401)
      end
    end
  end
end
