require 'eldr/rendering'
require 'eldr/sessions'
require 'eldr/responders'

class Purchases < Base
  include Eldr::Rendering
  include Eldr::Sessions
  include Eldr::Responders

  set :views_dir, File.join(__dir__, '../views')

  before :upgrade, :refund do
    @purchase = Purchase.find params['id']
    raise Errors::NotFound unless @purchase
  end

  before(:index, :upgrade, :refund) do
    raise Errors::NotAuthorized, 'Not Authorized' unless signed_in?
  end

  get '/purchases', name: :index do
    @purchases = current_user.purchases.all(refunded: false)
    render 'purchases'
  end

  post '/purchases', name: :create do
    PurchaseBook.new(package: Package.find_by_slug(params['package'] || 'book'),
                     user: current_user,
                     stripe_token: params['stripeToken'],
                     stripe_email: params['stripeEmail']).call(env)
  end

  put '/purchases/:id/upgrade', name: :upgrade do |env|
    UpgradePurchase.new(purchase: @purchase, package_slug: params['package']).call(env)
  end

  put '/purchases/:id/refund', name: :refund do |env|
    RefundPurchase.new(@purchase).call(env)
  end
end
