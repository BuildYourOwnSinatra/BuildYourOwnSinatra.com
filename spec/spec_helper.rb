require 'webmock/rspec'
require 'rack/test'
require 'rack'

require_relative '../app/app.rb'
ENV['SESSION_ID'] = 'test'
ENV['REDIS_URL']       = 'redis://127.0.0.1:6379/0'
ENV['REDIS_NAMESPACE'] = 'byos:sessions'

require 'stripe_mock'
WebMock.disable_net_connect!(:allow_localhost => true)

ENV['RACK_ENV'] = 'test'
Bundler.require :test

FactoryGirl.definition_file_paths = [
  File.join(File.dirname(__FILE__), 'factories')
]
FactoryGirl.find_definitions

def gen_omniauth_hash
  OmniAuth::AuthHash.new({
    :provider => 'github',
    :uid      => Faker::Internet.user_name.gsub('.','') + rand(0...1000).to_s,
    :info     => {
      :email    => "#{Faker::Internet.user_name}_#{rand(0...1000)}@example.org",
      :nickname => 'hurley'
    }
  })
end

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:github] = gen_omniauth_hash

def clean_db
  Identity.destroy_all
  Package.destroy_all
  Purchase.destroy_all
  User.destroy_all
end

clean_db()

module GlobalConfig
  extend RSpec::SharedContext
  let(:rt) do
    Rack::Test::Session.new(app)
  end

  let(:app) do
    App
  end
end

# Hardcode an instance into a global because rack-test likes to get too clever
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include GlobalConfig
  config.pattern = '**{,/*/**}/*_spec.rb'
end

def github_url(url)
  return url if url =~ /^http/

  url = File.join(Octokit.api_endpoint, url)
  uri = Addressable::URI.parse(url)
  uri.path.gsub!("v3//", "v3/")

  uri.to_s
end
