# frozen_string_literal: true

class NameChangeRequestsController < ApplicationController
  before_action :load_profile
  before_action :accreditors_from_first_accreditation

  def new
    @name_change_request = NameChangeRequest.new
    @accreditors = accreditors_from_first_accreditation
  end

  def create
    @name_change_request = NameChangeRequest.new(name_change_request_params)
    @name_change_request.profile = @profile

    if @name_change_request.save
      @name_change_request.selected_accreditors.each_key do |sciper|
        ProfileChangeMailer.with(
          name_change_request: @name_change_request,
          accreditor_sciper: sciper
        ).name_change_request.deliver_later
      end

      respond_to do |format|
        format.turbo_stream
        format.html do
          flash[:success] = t("profiles.name_change.flash_success")
          redirect_to edit_profile_path(@profile)
        end
      end
    else
      @accreditors = accreditors_from_first_accreditation
      render :new, status: :unprocessable_entity
    end
  end

  private

  def name_change_request_params
    params.require(:name_change_request).permit(
      :new_first,
      :new_last,
      :reason,
      accreditor_scipers: []
    )
  end

  def accreditors_from_first_accreditation
    @profile&.person&.accreditations&.first&.accreditors || []
  end

  def load_profile
    @profile = Profile.find_by!(sciper: Current.user.sciper)
  end
end
