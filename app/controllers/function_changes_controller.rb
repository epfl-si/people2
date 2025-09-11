# frozen_string_literal: true

class FunctionChangesController < ApplicationController
  before_action :load_and_authorize_accreditation
  before_action :set_accreditors

  # GET    /accreditations/:accreditation_id/function_changes/new
  def new
    if FunctionChange.where(accreditation_id: params[:accreditation_id]).count.positive?
      notifier t("msg.function_change_exists")
      nil
    else
      @function_change = FunctionChange.new(accreditation_id: params[:accreditation_id])
    end
  end

  # POST   /accreditations/:accreditation_id/function_changes(.:format)
  def create
    pp = params.require(:function_change).permit(
      :function_en, :function_fr, :function_it, :function_de, :reason, accreditor_scipers: []
    ).merge({
              accreditation_id: params[:accreditation_id],
              requested_by: Current.user.sciper
            })
    @function_change = FunctionChange.new(pp)
    if @function_change.save
      @function_change.selected_accreditors.each_key do |as|
        ProfileChangeMailer.with(
          function_change: @function_change,
          accreditor_sciper: as
        ).function_change_request.deliver_later
      end
      turbo_flash(:success)
    else
      @have_errors = true
      turbo_flash(:error)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def load_and_authorize_accreditation
    @accreditation = Accreditation.find(params[:accreditation_id])
    authorize! @accreditation, to: :update?
  end

  def set_accreditors
    @accreditors = @accreditation.accreditors
  end
end
