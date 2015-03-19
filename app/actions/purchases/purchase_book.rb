require_relative '../../services/stripe/create_customer'
require_relative '../../services/stripe/charge'
require_relative '../../services/github/add_team_membership'

class PurchaseBook < Eldr::Action
  include Eldr::Responders
  attr_accessor :purchase, :user, :stripe_token, :env
  set :views_dir, File.join(__dir__, '../../views')

  def initialize(user:, package:, stripe_token:)
    @purchase = Purchase.new
    @purchase.user    = user
    @purchase.packages << package

    @user          = user
    @stripe_token  = stripe_token
  end

  def call(env) # rubocop:disable
    @env = env

    customer = CreateCustomer.new(email: user.email, stripe_token: stripe_token)
    customer.call(env)

    @message = 'Book Purchased!'

    unless customer.valid?
      purchase.errors.merge!(customer.errors)
      return respond(purchase, location: '/#buy', message: 'Could not create customer at Stripe! Contact Support!')
    end

    charge = Charge.new(price: purchase.package.price, customer_id: customer.id)
    charge.call(env)

    if charge.valid?
      user.stripe_id = customer.id
      user.save

      purchase.charge_id = charge.id
      purchase.price     = purchase.package.price
      purchase.save
    else
      purchase.errors.merge!(charge.errors)
      return respond(purchase, location: '/#buy', message: 'Could not charge you! Contact Support!')
    end

    add_team_member = AddTeamMembership.new(username: user.username)
    add_team_member.call(env)

    unless add_team_member.valid?
      purchase.errors.merge!(add_team_member.errors)
      @message = 'Could not add you to the GitHub repo! Contact me!'
    end

    respond(purchase, force_redirect: true, location: ENV['READ_URL'], message: @message)
  end
end
