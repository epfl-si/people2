# frozen_string_literal: true

class ProfileChangeMailer < ApplicationMailer
  def function_change_request(profile, reason)
    @profile = profile
    @reason  = reason
    recipients = profile.accreditors.map(&:email)
    mail(to: recipients, subject: "Demande de changement de fonction pour #{profile.name}")
  end

  def name_change_request
    @request = params[:name_change_request]
    person = @request.profile.person
    subject_text = "Demande de changement de nom usuel – #{person.name.display} (#{person.sciper})"

    mail(
      to: ENV.fetch("NAME_CHANGE_REQUEST_EMAIL"),
      subject: subject_text
    )
  end
end
