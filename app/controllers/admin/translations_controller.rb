# frozen_string_literal: true

# TODO: for nicer inline editing
#   see https://andrewfoster.hashnode.dev/inline-editing-and-deleting-with-hotwire-part-2
module Admin
  class TranslationsController < ApplicationController
    before_action :set_admin_translation, only: %i[show edit update autotranslate propagate]

    # GET /admin/translations or /admin/translations.json
    def index
      # TODO: stats per file
      @translations = Admin::Translation.forui.todo.order(:en) # .limit(40)
    end

    # GET /admin/translations/1 or /admin/translations/1.json
    def show; end

    # GET /admin/translations/1/edit
    def edit; end

    # PATCH/PUT /admin/translations/1 or /admin/translations/1.json
    def update
      @admin_translation.update(admin_translation_params)
      # respond_to do |format|
      #   format.turbo_stream
      # end
    end

    def autotranslate
      @admin_translation.autotranslate
      @admin_translation.save
      render action: 'update'
    end

    # Find all translation with the same content in english and clone the current translation
    def propagate
      @translations = Admin::Translation.where(Admin::Translation::DL => @admin_translation[Admin::Translation::DL])
      @translations.each do |t|
        Admin::Translation::OTHER_LANGS.each do |l|
          t[l] = @admin_translation[l]
        end
        t.save
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_admin_translation
      @admin_translation = Admin::Translation.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def admin_translation_params
      params.expect(admin_translation: %i[en fr it de done])
    end
  end
end
