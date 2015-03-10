describe Main do
  describe 'GET /' do
    it 'returns 200 OK' do
      get '/'
      expect(last_response.status).to eq(200)
    end
  end
end
