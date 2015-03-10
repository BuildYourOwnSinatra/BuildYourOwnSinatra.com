describe Users do
  describe 'GET /login' do
    it 'redirects to /auth/github' do
      get '/login'
      expect(last_response.status).to eq(303)
      expect(last_response.headers['Location']).to eq('/auth/github')
    end
  end

  describe 'POST /auth/github/callback' do
    context 'when valid data' do
      it 'redirects to /#buy' do
        post '/auth/github/callback', nil, {'omniauth.auth' => OmniAuth.config.mock_auth[:github]}
        expect(last_response.status).to eq(303)
      end
    end

    context 'when no omniauth identity' do
      it 'returns not authorized' do
        post '/auth/github/callback'
        expect(last_response.status).to eq(401)
      end
    end
  end
end
