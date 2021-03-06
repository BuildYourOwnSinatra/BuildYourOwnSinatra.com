require 'bundler/setup'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../app', __FILE__)

ENV['MONGODB_URI']    ||= ENV['MONGO_URI']
ENV['MONGODB_URI']    ||= 'mongodb://localhost:27017/byos'
ENV['ASSETS_PATH']    ||= File.join(__dir__, '/assets')
ENV['APP_ROOT']       ||= File.join(__dir__)
ENV['RACK_ENV']       ||= 'development'
ENV['READ_URL']       ||= 'https://book.buildYourOwnSinatra.com'

require 'require_all'
require 'stripe'
require 'octokit'
require 'kramdown'
require 'rouge'
require 'eldr'
require 'eldr/cascade'
require 'eldr/sessions'
require 'eldr/action'
require 'eldr/responders'
require 'eldr/assets'
require 'rack/robustness'
require 'rack/session/moneta'
require 'omniauth-github'
require 'build-your-own-sinatra'
require 'slim'
Slim::Embedded::Engine.disable_option_validator!
Slim::Embedded::Engine.set_options markdown: { input: 'GFM', syntax_highlighter: 'rouge' }

Stripe.api_key = ENV['STRIPE_SECRET']

require_rel 'responses/**/*.rb'
require_rel 'services/**/*.rb'
require_rel 'actions/**/*.rb'
require_rel 'controllers/*.rb'

require 'sprockets'
require 'sprockets-sass'
require 'sass'
require 'bourbon'
require 'opal'

opal = Opal::Server.new do |s|
  s.main = 'app'
  s.append_path 'app/assets/js'
end

sprockets_env = Sprockets::Environment.new do |env|
  env.append_path 'app/assets/css'
end

App = Rack::Builder.new do
  # Catch Explosions of the worst kind
  use Rack::Robustness do |g|
    g.status 500
    g.content_type 'text/plain'
    g.body 'Sorry, my backend exploded! Mention me (@k_2052) and let me know!'
  end

  use Rack::Static, root: File.join(__dir__, 'assets'), urls: ['/images']

  map '/assets/js' do
    run opal.sprockets
  end

  map '/assets/css' do
    run sprockets_env
  end

  run Eldr::Cascade.new([Main, Users, Purchases])
end
