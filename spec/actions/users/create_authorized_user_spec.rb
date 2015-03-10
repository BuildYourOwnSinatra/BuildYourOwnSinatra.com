require 'ostruct'

describe CreateAuthorizedUser do
  describe '.new' do
    it 'returns a new instance of CreateAuthorizedUser' do
      expect(CreateAuthorizedUser.new).to be_instance_of CreateAuthorizedUser
    end
  end

  describe '#call' do
    context 'when not logged in and no omniauth hash' do
      subject(:create_authorized_user) { CreateAuthorizedUser.new }

      it 'raises NotAuthorized' do
        expect { create_authorized_user.call({}) }.to raise_error(Errors::NotAuthorized)
      end
    end

    context 'when not logged in and omniauth hash is available' do
      let(:env) do
        env = Rack::MockRequest.env_for('/auth/github/callback', {
          :method => :post,
          "rack.session" => {}
        })
        env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
        env['x-rack.flash'] ||= Rack::Flash::FlashHash.new(env['rack.session'], {accessorize: [:notice, :error] })
        env['eldr.request'] ||= Rack::Request.new(env)
        env['eldr.route'] = OpenStruct.new(name: nil)
        env
      end

      subject(:create_authorized_user) { CreateAuthorizedUser.new }

      it 'returns a response with a user' do
        resp = create_authorized_user.call(env)
        expect(resp.object).to be_instance_of User
      end

      it 'sets current_user' do
        resp = create_authorized_user.call(env)
        expect(resp.env['rack.session'][ENV['SESSION_ID']]).to_not be_nil
        expect(resp.env['rack.session'][ENV['SESSION_ID']]).to eq(resp.object.id)
      end

      describe 'user response' do
        it 'has the details from the identity' do
          resp = create_authorized_user.call(env)
          user = resp.object
          identity = Identity.find_with_omniauth(env['omniauth.auth'])
          expect(user.email).to eq(identity.email)
          expect(user.username).to eq(identity.username)
        end
      end

      it 'redirects to /' do
        resp = create_authorized_user.call(env)
        expect(resp.status).to eq(303)
        expect(resp.headers['Location']).to eq('/#buy')
      end
    end

    context 'when logged in' do
      let(:user) do
        FactoryGirl.create(:user)
      end

      let(:env) do
        env = Rack::MockRequest.env_for('/auth/github/callback', {
          :method => :post,
          'rack.session' => {"#{ENV['SESSION_ID']}" => user.id}
        })
        env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
        env['x-rack.flash'] ||= Rack::Flash::FlashHash.new(env['rack.session'], {accessorize: [:notice, :error] })
        env['eldr.request'] ||= Rack::Request.new(env)
        env['eldr.route'] = OpenStruct.new(name: nil)
        env
      end

      subject(:create_authorized_user) { CreateAuthorizedUser.new }

      it 'returns a user that matches the logged in user' do
        resp = create_authorized_user.call(env)
        expect(resp.object.id).to eq(user.id)
      end
    end
  end
end
