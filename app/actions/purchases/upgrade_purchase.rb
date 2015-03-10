require_relative '../../services/stripe/charge'

class UpgradePurchase < Eldr::Action
  include Eldr::Responders
  attr_accessor :purchase, :package, :user, :message, :env
  set :views_dir, File.join(__dir__, '../../views')

  def initialize(purchase:, package_slug:)
    @purchase = purchase
    @package  = Package.find_by_slug package_slug
    @user     = @purchase.user
  end

  def call(env)
    @env = env

    charge = Charge.new(price: package.price - purchase.price, customer_id: user.stripe_id)
    charge.call(env)

    if charge.valid?
      purchase.upgrade!(package, charge.id)
      @message = "Upgraded you to: #{@package.name}"
    else
      purchase.errors.merge!(charge.errors)
      @message = 'Could not upgrade your purchase! Contact Me!'
    end

    respond(purchase, location: '/purchases', message: @message)
  end
end
