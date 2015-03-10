module Errors
  class NotAuthorized < StandardError
    def call(_env)
      Rack::Response.new message, 401
    end
  end
end
