# frozen_string_literal: true

class FunctionChangesController < ApplicationController
  before_action :set_accreditation
  before_action :set_accreditors

  # GET    /accreditations/:accreditation_id/function_changes/new
  def new
    @function_change = FunctionChange.new(accreditation_id: params[:accreditation_id])
  end

  # POST   /accreditations/:accreditation_id/function_changes(.:format)
  def create
    pp = params.require(:function_change).permit(
      :function, :reason, accreditor_scipers: []
    ).merge({
              accreditation_id: params[:accreditation_id],
              requested_by: Current.user.sciper
            })
    @function_change = FunctionChange.new(pp)
    respond_to do |format|
      if @function_change.save
        @function_change.selected_accreditors.each_key do |as|
          FunctionChangeMailer.with(
            function_change: @function_change,
            accreditor_sciper: as
          ).accreditor_request.deliver_later
        end
        format.turbo_stream do
          # flash.now[:success] = "flash.generic.success.create"
          render :create
        end
        format.json { render :show, status: :created }
      else
        format.turbo_stream do
          # flash.now[:error] = "flash.generic.error.create"
          @have_errors = true
          render :new, status: :unprocessable_entity
        end
        format.json { render json: @function_change.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_accreditation
    @accreditation = Accreditation.find(params[:accreditation_id])
  end

  def set_accreditors
    @accreditors = @accreditation.accreditors
  end
end
