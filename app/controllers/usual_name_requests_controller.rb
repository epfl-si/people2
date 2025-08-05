# frozen_string_literal: true

# Custom non-standard usual name change must be validated and cannot be done
# automatically. Therefore, we just send an email to the responsible service.
class UsualNameRequestsController < ApplicationController
  before_action :load_and_authorize_profile

  def new
    @unr = UsualNameRequest.for(@profile)
  end

  def create
    @unr = UsualNameRequest.for(@profile)
    if @unr&.update(usual_name_request_params)
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render turbo_stream: turbo_stream.update("usual_name_request_form", partial: "form", locals: { unr: @unr })
    end
  end

  private

  def usual_name_request_params
    params.require(:usual_name_request).permit(
      :new_first,
      :new_last,
      :reason
    )
  end

  def load_profile_and_name_request
    @profile = Profile.find_by!(sciper: Current.user.sciper)
    @unr = UsualNameRequest.for(@profile)
  end
end
