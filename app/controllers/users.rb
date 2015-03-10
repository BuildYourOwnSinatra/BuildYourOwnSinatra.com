require 'eldr/rendering'
require 'eldr/sessions'
require 'eldr/responders'

class Users < Base
  include Eldr::Sessions
  include Eldr::Rendering
  include Eldr::Responders
  use Rack::Session::Redis, redis_server: "#{ENV['REDIS_URL']}/#{ENV['REDIS_NAMESPACE']}"

  def auth_hash
    env['omniauth.auth']
  end

  get '/login' do
    response = Rack::Response.new '', 303
    response['Location'] = '/auth/github'
    response
  end

  post '/auth/:provider/callback', CreateAuthorizedUser.new
end
