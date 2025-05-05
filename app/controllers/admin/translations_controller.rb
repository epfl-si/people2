# frozen_string_literal: true

module Admin
  class TranslationsController < ApplicationController
    before_action :set_admin_translation, only: %i[show edit update]

    # GET /admin/translations or /admin/translations.json
    def index
      # TODO: stats per file
      @translations_by_file = Admin::Translation.where(done: false).group_by(&:file)
    end

    # GET /admin/translations/1 or /admin/translations/1.json
    def show; end

    # GET /admin/translations/new
    def new
      @admin_translation = Admin::Translation.new
    end

    # GET /admin/translations/1/edit
    def edit; end

    # PATCH/PUT /admin/translations/1 or /admin/translations/1.json
    def update
      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_admin_translation
      @admin_translation = Admin::Translation.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def admin_translation_params
      params.expect(admin_translation: %i[file en fr it de done])
    end
  end
end
