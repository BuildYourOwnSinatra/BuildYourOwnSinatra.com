describe Errors::NotFound do
  describe '.new' do
    it 'returns a new instance' do
      expect(Errors::NotFound.new).to be_instance_of Errors::NotFound
    end

    it 'has a message' do
      error = Errors::NotFound.new('cats')
      expect(error.message).to eq('cats')
    end
  end

  describe '#call' do
    subject(:error) { Errors::NotFound.new('cats') }

    it 'returns an instance of Rack::Response' do
      resp = error.call({})
      expect(resp).to be_instance_of Rack::Response
    end

    it 'has a 401 status' do
      resp = error.call({})
      expect(resp.status).to eq(404)
    end
  end
end
