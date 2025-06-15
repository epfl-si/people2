# frozen_string_literal: true

class UsualNameChangesController < ApplicationController
  before_action :load_and_authorize_profile
  def new
    @unc = UsualNameChange.for(@profile)
  end

  def create
    @unc = UsualNameChange.for(@profile)

    if @unc&.update(unc_params)
      flash.now[:success] = ".usual_name_change.create"
    else
      render turbo_stream: turbo_stream.update("usual_name_change_form", partial: "form")
    end
  end

  private

  def unc_params
    params.require(:usual_name_change).permit(:new_first, :new_last)
  end
end
