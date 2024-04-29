# frozen_string_literal: true

class ProfilesController < ApplicationController
  protect_from_forgery
  before_action :ensure_auth

  def edit
    @profile = Profile.find(params[:id])
    # @profile.experiences.build
    @person = Person.find(@profile.sciper)
    @name = @person.name
    respond_to do |format|
      format.html do
        render
      end
    end
  end

  private

  # TODO: implement this!
  def ensure_auth
    true
  end

  def profile_params
    params.require(:profile).permit(
      :nationality_fr, :nationality_en,
      :title_fr, :title_en,
      :personal_web_url,
      :show_function, :show_phone, :show_nationality, :show_title, :show_weburl,
      :experiences, experiences_attributes: %i[
        title_en title_fr location
        year_begin year_end audience visible
      ]
    )
  end
end
