# frozen_string_literal: true

class ProfileChangeMailer < ApplicationMailer
  def function_change_request
    @function_change = params[:function_change]
    @accreditor_sciper = params[:accreditor_sciper]
    @accreditor = Person.find(@accreditor_sciper)
    @accreditation = @function_change.accreditation
    @person = @function_change.person
    mail(
      to: @accreditor.email.to_s,
      subject: t("mailer.function_change.subject", name: @person.name.display)
    )
  end

  def usual_name_request
    @name_change_request = params[:usual_name_request]
    @person = @name_change_request.profile.person
    subject_text = "Demande de changement de nom usuel – #{@person.name.display} (#{@person.sciper})"

    mail(
      to: ENV.fetch("NAME_CHANGE_REQUEST_EMAIL"),
      subject: subject_text
    )
  end
end
