module Errors
  class NotFound < StandardError
    def call(_env)
      Rack::Response.new message, 404
    end
  end
end
