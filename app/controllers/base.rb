class Base < Eldr::App
  include Eldr::Sessions
  include Eldr::Responders
  include Eldr::Assets

  uri = URI.parse(ENV['MONGODB_URI'])
  ENV['SESSIONS_DOMAIN'] ||= '127.0.0.1'
  use Rack::Session::Moneta, domain: ENV['SESSIONS_DOMAIN'], store: Moneta.new(:Mongo, {
    :host     => uri.host,
    :port     => uri.port,
    :db       => uri.path.gsub(/^\//, ''),
    :user     => uri.user,
    :password => uri.password,
  })
  use Rack::Flash, accessorize: [:notice, :error]

  set :views_dir, File.join(__dir__, '../views')

  use OmniAuth::Builder do
    provider :identity, fields: [:email]
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email' if ENV.include? 'GITHUB_KEY'
  end
end
