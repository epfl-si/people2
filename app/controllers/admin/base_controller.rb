# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authentication
    before_action :admin_only!
    layout 'admin'

    private

    def admin_only!
      authorize! Admin, to: :manage?
    end
  end
end
