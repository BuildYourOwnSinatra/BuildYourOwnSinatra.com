require 'eldr/rendering'

class Main < Eldr::App
  include Eldr::Rendering
  include Eldr::Assets
  include Eldr::Sessions

  use Rack::Session::Redis, namespace: ENV['REDIS_NAMESPACE'], url: ENV['REDIS_URL']
  use Rack::Flash, accessorize: [:notice, :error]

  set :views_dir, File.join(__dir__, '../views')

  get '/' do
    render 'index'
  end
end
