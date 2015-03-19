class Charge < Eldr::Action
  attr_accessor :price, :customer_id, :amount, :stripe_charge, :id

  def initialize(price: 3500, customer_id: nil)
    @price       = price
    @amount      = price
    @customer_id = customer_id
  end

  def call(_env = {})
    begin
      @stripe_charge = Stripe::Charge.create(amount:      price,
                                             currency:    'usd',
                                             customer:     customer_id,
                                             description: 'Purchase of Build your Own Sinatra')
      @id = @stripe_charge.id
      @stripe_charge
    rescue => error
      handle_error(error)
    end
  end

  private

  def handle_error(error)
    case error
    when Stripe::CardError
      errors.add :base, 'Your card was Declined!'
    when Stripe::InvalidRequestError, Stripe::AuthenticationError, Stripe::APIConnectionError
      errors.add :base, 'Unable to process this purchase. Please email me: k@2052.me'
    when Stripe::StripeError
      errors.add :base, 'Unable to process this purchase. Please email me: k@2052.me'
    else
      errors.add :base, 'Unable to process this purchase. Please email me: k@2052.me'
    end

    self
  end
end
