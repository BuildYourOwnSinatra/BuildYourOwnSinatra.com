describe Errors::NotAuthorized do
  describe '.new' do
    it 'returns a new instance' do
      expect(Errors::NotAuthorized.new).to be_instance_of Errors::NotAuthorized
    end

    it 'has a message' do
      error = Errors::NotAuthorized.new('cats')
      expect(error.message).to eq('cats')
    end
  end

  describe '#call' do
    subject(:error) { Errors::NotAuthorized.new('cats') }

    it 'returns an instance of Rack::Response' do
      resp = error.call({})
      expect(resp).to be_instance_of Rack::Response
    end

    it 'has a 401 status' do
      resp = error.call({})
      expect(resp.status).to eq(401)
    end
  end
end
