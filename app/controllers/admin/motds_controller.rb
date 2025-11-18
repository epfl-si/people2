# frozen_string_literal: true

module Admin
  class MotdsController < BaseController
    before_action :load_motd, only: %i[show edit update destroy]

    def index
      @motds = Motd.all
    end

    def new
      @motd = Motd.new(expiration: Time.zone.tomorrow, level: "info")
    end

    def show; end

    def edit; end

    def create
      @motd = Motd.create(motd_params)
      if @motd
        redirect_to [:admin, @motd]
      else
        render action: :new
      end
    end

    def update
      if @motd.update(motd_params)
        redirect_to [:admin, @motd]
      else
        render action: :edit
      end
    end

    def destroy
      @motd.destroy
      redirect_to admin_motds_path
    end

    private

    def load_motd
      @motd = Motd.find(params[:id])
    end

    def motd_params
      params.require(:motd).permit(
        :title_fr, :title_en, :title_it, :title_de,
        :public, :expiration, :level, :category_id
      )
    end
  end
end
