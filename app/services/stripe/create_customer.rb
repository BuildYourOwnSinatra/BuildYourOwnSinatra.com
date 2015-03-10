class CreateCustomer < Eldr::Action
  attr_accessor :email, :stripe_token, :id, :customer

  def initialize(email:, stripe_token:)
    @email        = email
    @stripe_token = stripe_token
  end

  def call(_env = {})
    begin
      customer = Stripe::Customer.create(
        email: email,
        card:  stripe_token
      )

      @id = customer.id
      customer
    rescue => error
      handle_error(error)
    end
  end

  private

  def handle_error(error)
    case error
    when Stripe::InvalidRequestError, Stripe::AuthenticationError, Stripe::APIConnectionError
      errors.add :base, 'Unable to process this purchase. Please email me: k@2052.me'
    when Stripe::StripeError
      errors.add :base, 'Unable to process this purchase. Please email me: k@2052.me'
    else
      errors.add :base, 'Unable to process this purchase. Please email me: k@2052.me'
    end
  end
end
