require 'eldr/rendering'

class Main < Eldr::App
  include Eldr::Rendering
  include Eldr::Assets
  include Eldr::Sessions

  uri = URI.parse(ENV['MONGODB_URI'])
  use Rack::Session::Moneta, domain: ENV['SESSIONS_DOMAIN'], store: Moneta.new(:Mongo, {
    :host     => uri.host,
    :port     => uri.port,
    :db       => uri.path.gsub(/^\//, ''),
    :user     => uri.user,
    :password => uri.password
  })
  use Rack::Flash, accessorize: [:notice, :error]

  set :views_dir, File.join(__dir__, '../views')

  get '/' do
    render 'index'
  end
end
