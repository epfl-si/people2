# frozen_string_literal: true

module API
  class IpController < ApplicationController
    allow_unauthenticated_access
    def index
      res = "remote_ip: #{request.remote_ip}\n"
      res << "HTTP_X_FORWARDED_FOR: #{request.headers['HTTP_X_FORWARDED_FOR']}\n"
      render inline: res, content_type: 'text/plain'
    end
  end
end
