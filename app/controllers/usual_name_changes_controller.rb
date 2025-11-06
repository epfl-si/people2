# frozen_string_literal: true

class UsualNameChangesController < ApplicationController
  MAX_COUNT = 3
  before_action :load_and_authorize_profile_and_name
  def new
    @msg = nil
    n = @profile.usual_name_changes.count
    if n.positive?
      if n >= MAX_COUNT
        @msg = 'quota_exceded'
      else
        @unc = @profile.usual_name_changes.order(:created_at).last
        @msg = 'pending' unless @unc.done? || @unc.retriable?
      end
    end
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @unc ||= UsualNameChange.for(@profile, @name)
    # rubocop:enable Naming/MemoizedInstanceVariableName
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
    person = Person.find_by_sciper(@profile.sciper, auth: jwt)
    @name = person.name
  end
end
