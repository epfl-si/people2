# frozen_string_literal: true

module Admin
  class ServiceAuthsController < BaseController
    before_action :load_auth, only: %i[show edit update destroy]
    before_action :set_service_select, only: %i[new create edit update]
    def index
      @auths = ServiceAuth.all
    end

    def new
      @auth = ServiceAuth.new
      @type_select = ServiceAuth::TYPES.map { |k| [k.human_name, k.name] }
    end

    def show; end

    def edit; end

    def create
      @auth = ServiceAuth.create(auth_params(:type))
      if @auth
        redirect_to [:admin, @auth]
      else
        render action: :new
      end
    end

    def update
      if @auth.update(auth_params)
        redirect_to [:admin, @auth]
      else
        render action: :edit
      end
    end

    def destroy
      @auth.destroy
      redirect_to admin_service_auths_path
    end

    private

    def load_auth
      @auth = ServiceAuth.find(params[:id])
    end

    def set_service_select
      @service_select = ServiceAuth::SERVICES.to_a.map(&:reverse)
    end

    def auth_params(*extra)
      all_params = (%i[service subnet user password comment email audience] + extra).uniq
      params.require(:service_auth).permit(all_params)
    end
  end
end
