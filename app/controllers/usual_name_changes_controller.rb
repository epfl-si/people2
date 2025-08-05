# frozen_string_literal: true

class UsualNameChangesController < ApplicationController
  before_action :load_and_authorize_profile
  def new
    @unc = UsualNameChange.for(@profile)
  end

  def create
    @unc = UsualNameChange.for(@profile)

    # if @unc&.update(new_first: "ciccio", new_last: "pasticcio")
    if @unc&.update(unc_params)
      turbo_flash(:success)
    else
      turbo_flash(:error)
      render turbo_stream: turbo_stream.update("usual_name_change_form", partial: "form")
    end
  end

  private

  def unc_params
    params.require(:usual_name_change).permit(:new_first, :new_last)
  end
end
