# frozen_string_literal: true

module Admin
  class VersionsController < BaseController
    before_action :admin_only!

    # GET /admin/versions
    def index
      @versions = Work::Version.order('created_at DESC').limit(100)
    end

    # GET /admin/versions/1
    def show
      @version = Work::Version.find(params[:id])
    end
  end
end
