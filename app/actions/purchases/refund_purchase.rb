require_relative '../../services/stripe/refund'

class RefundPurchase < Eldr::Action
  include Eldr::Responders
  attr_accessor :purchase, :message, :env
  set :views_dir, File.join(__dir__, '../../views')

  def initialize(purchase)
    @purchase = purchase
  end

  def call(env)
    @env = env

    refund = Refund.new(charge_id: purchase.charge_id)
    refund.call(env)

    if refund.valid?
      purchase.refund!(refund)
      @message = 'Refunded Your Purchase'
    else
      @message = 'Could not refund your purchase!! Contact support!'
      purchase.errors.merge!(refund.errors)
    end

    respond(purchase, location: '/purchases', message: message)
  end
end
