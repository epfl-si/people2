# frozen_string_literal: true

class ProfilesController < ApplicationController
  protect_from_forgery
  before_action :ensure_auth

  def edit
    @profile = Profile.find(params[:id])
    @person = Person.find(@profile.sciper)
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
end
