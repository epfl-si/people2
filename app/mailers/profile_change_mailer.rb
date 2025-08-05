# frozen_string_literal: true

class ProfileChangeMailer < ApplicationMailer
  def accreditor_request
    @function_change = params[:function_change]
    @accreditor_sciper = params[:accreditor_sciper]
    @accreditor = Person.find_by(sciper: @accreditor_sciper)

    mail(
      to: @accreditor.email.to_s,
      subject: t("mailer.function_change.subject", name: @function_change.accreditation.person.display_name)
    )
  end

  def usual_name_request
    @request = params[:usual_name_request]
    person = @request.profile.person
    subject_text = "Demande de changement de nom usuel – #{person.name.display} (#{person.sciper})"

    mail(
      to: ENV.fetch("NAME_CHANGE_REQUEST_EMAIL"),
      subject: subject_text
    )
  end
end
