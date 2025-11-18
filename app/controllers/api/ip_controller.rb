# frozen_string_literal: true

module API
  class IpController < ApplicationController
    allow_unauthenticated_access
    def index
      render inline: request.remote_ip, content_type: 'text/plain'
    end
  end
end
