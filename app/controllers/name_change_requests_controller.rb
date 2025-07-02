# frozen_string_literal: true

class NameChangeRequestsController < ApplicationController
  before_action :load_profile

  def new
    @name_change_request = NameChangeRequest.for(@profile) || NameChangeRequest.new
  end

  def create
    @name_change_request = NameChangeRequest.for(@profile) || NameChangeRequest.new
    @name_change_request.assign_attributes(name_change_request_params)

    if @name_change_request.save
      ProfileChangeMailer.with(name_change_request: @name_change_request)
                         .name_change_request
                         .deliver_later

      respond_to do |format|
        format.turbo_stream
        format.html do
          flash[:success] = t("profiles.name_change.flash_success")
          redirect_to edit_profile_path(@profile)
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def name_change_request_params
    params.require(:name_change_request).permit(
      :new_first,
      :new_last,
      :reason
    )
  end

  def load_profile
    @profile = Profile.find_by!(sciper: Current.user.sciper)
  end
end
