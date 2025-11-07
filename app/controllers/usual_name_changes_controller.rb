# frozen_string_literal: true

class UsualNameChangesController < ApplicationController
  MAX_COUNT = 3
  before_action :load_and_authorize_profile_and_name
  def new
    @msg = nil
    n = @profile.usual_name_changes.count
    if n > MAX_COUNT
      @msg = 'quota_exceded'
      return
    end

    if n.positive?
      # If the last request is retriable that is enough time is passed and
      # it is still not affective. We just consider it failed and replace it.
      unc = @profile.usual_name_changes.order(:created_at).last
      unless unc.done?
        if unc.retriable?
          unc.destroy
        else
          @msg = 'pending'
          return
        end
      end
    end
    @unc = UsualNameChange.for(@profile, @name)
  end

  def create
    @unc = UsualNameChange.for(@profile, @name, unc_params)

    if @unc.blank?
      turbo_flash(:error, message: t('.invalid'))
      return
    end

    if @unc.useless?
      turbo_flash(:success, message: t('.nothing_todo'))
      return
    end

    # if @unc&.update(new_first: "ciccio", new_last: "pasticcio")
    if @unc.save
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

  def load_and_authorize_profile_and_name
    @profile = Profile.find params[:profile_id]
    authorize! @profile, to: :confidential_edit?

    jwt = Current.session.jwt
    person = Person.find_by_sciper(@profile.sciper, auth: jwt, force: true)
    @profile.person = person
    @name = person.name
  end
end
