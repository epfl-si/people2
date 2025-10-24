# frozen_string_literal: true

module Admin
  class SpecialOptionsController < BaseController
    before_action :load_option, only: %i[edit update destroy]

    def index
      @options = SpecialOption.all
    end

    def new
      @option = SpecialOption.new
    end

    def edit; end

    def create
      # Rails is great so the saved object has the right class => passed validations
      @option = SpecialOption.new(so_params)
      if @option.save
        redirect_to admin_special_options_path
      else
        Rails.logger.debug("===== could not save: errors: #{@option.errors.inspect}")
      end
    end

    def update
      if @option.update(so_params)
        redirect_to admin_special_options_path
      else
        render action: edit
      end
    end

    def destroy
      @option.destroy
      redirect_to admin_special_options_path
    end

    private

    def load_option
      @option = SpecialOption.find(params[:id])
    end

    def so_params
      k = @option&.class&.name&.underscore&.to_sym || :special_option
      params.require(k).permit(
        :sciper, :type, :data
      )
    end
  end
end
