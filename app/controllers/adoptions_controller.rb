# frozen_string_literal: true

class AdoptionsController < ApplicationController
  # PATCH/PUT /awards/1 or /awards/1.json
  def update
    @adoption = Adoption.find(params[:id])
    authorize! @adoption, to: :update?

    if @adoption.update(adoption_params)
      Yabeda.people.adoptions_count.set({}, Adoption.accepted.count)
      redirect_to person_path(sciper_or_name: @adoption.sciper)
    else
      flash[:error] = "flash.error_saving_profile_adoption"
      redirect_to preview_path(sciper_or_name: @adoption.sciper)
    end
  end

  private

  def adoption_params
    params.require(:adoption).permit(:accepted)
  end
end
