# frozen_string_literal: true

class FunctionChangeMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.function_change_mailer.accreditor_request.subject
  #
  def accreditor_request
    @function_change = params[:function_change]
    @person = @function_change.person
    @accreditation = @function_change.accreditation
    @accreditor = @function_change.selected_accreditors[params[:accreditor_sciper]]

    @greeting = "Hi"

    mail to: @accreditor.email
  end
end
