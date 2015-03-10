class CreateAuthorizedUser < Eldr::Action
  include Eldr::Sessions
  include Eldr::Responders
  set :views_dir, File.join(__dir__, '../../views')

  attr_accessor :user, :env

  def call(env)
    @env = env
    auth = env['omniauth.auth']

    raise Errors::NotAuthorized, 'Did you login?' unless auth

    @identity = Identity.find_or_create_with_omniauth(auth)
    @message  = 'Signed in!'

    if signed_in?
      if @identity.user == current_user
        @message = 'Already linked that account!'
      else
        @identity.user = current_user
        @identity.save
        @message = 'Successfully linked that account!'
      end
    end

    unless @identity.user.present?
      user = User.create_with_identity(@identity)
      return respond(user, error: 'Invalid User') unless user.valid?

      @identity.user = user
      @identity.save
    end

    set_current_user @identity.user

    respond(current_user, location: '/#buy', notice: @message)
  end
end
