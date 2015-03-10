class Refund < Eldr::Action
  attr_accessor :id, :refund, :charge_id

  def initialize(charge_id:)
    @charge_id = charge_id
  end

  def call(_env = {})
    begin
      charge = Stripe::Charge.retrieve(charge_id)
      @refund = charge.refunds.create
      @id = refund.id
      @refund
    rescue => error
      handle_error(error)
    end
  end

  def handle_error(error)
    case error
    when Stripe::CardError
      errors.add :base, 'Your card was Declined!'
    when Stripe::InvalidRequestError, Stripe::AuthenticationError, Stripe::APIConnectionError
      errors.add :base, 'Unable to refund your purchase. Please email me: k@2052.me'
    when Stripe::StripeError
      errors.add :base, 'Unable to refund your purchase. Please email me: k@2052.me'
    else
      errors.add :base, 'Unable to refund your purchase. Please email me: k@2052.me'
    end
  end
end
