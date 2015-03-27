class Base < Eldr::App
  include Eldr::Sessions
  include Eldr::Responders
  include Eldr::Assets

  # TODO: Fix the domain sesisons issue
  # provider_ignores_state shouldn't be used. it's security risk.
  # sincee we have no write permisions, the only thing a user could steal is a book so not a big risk
  use OmniAuth::Builder do
    provider :identity, fields: [:email]
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email',     provider_ignores_state: true if ENV.include? 'GITHUB_KEY'
  end

  uri = URI.parse(ENV['MONGODB_URI'])
  use Rack::Session::Moneta, domain: ENV['SESSIONS_DOMAIN'], store: Moneta.new(:Mongo, {
    :host     => uri.host,
    :port     => uri.port,
    :db       => uri.path.gsub(/^\//, ''),
    :user     => uri.user,
    :password => uri.password,
  })
  use Rack::Flash, accessorize: [:notice, :error]

  set :views_dir, File.join(__dir__, '../views')
end
