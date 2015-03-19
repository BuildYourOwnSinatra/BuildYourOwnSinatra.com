class Base < Eldr::App
  include Eldr::Sessions
  include Eldr::Responders
  include Eldr::Assets

  use Rack::Session::Redis, redis_server: "#{ENV['REDIS_URL']}/#{ENV['REDIS_NAMESPACE']}"
  use Rack::Flash, accessorize: [:notice, :error]

  set :views_dir, File.join(__dir__, '../views')

  use OmniAuth::Builder do
    provider :identity, fields: [:email]
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email' if ENV.include? 'GITHUB_KEY'
  end
end
