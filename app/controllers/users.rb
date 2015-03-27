require 'eldr/rendering'
require 'eldr/sessions'
require 'eldr/responders'

class Users < Base
  include Eldr::Sessions
  include Eldr::Rendering
  include Eldr::Responders

  def auth_hash
    env['omniauth.auth']
  end

  get '/login-with-github-then-buy' do
    response = Rack::Response.new '', 303
    response['Location'] = '/auth/github'
    response
  end

  get '/auth/:provider/callback',  CreateAuthorizedUser.new
  post '/auth/:provider/callback', CreateAuthorizedUser.new
end
