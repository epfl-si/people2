# frozen_string_literal: true

# TODO: 12 factor from address
class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@epfl.ch'
  layout 'mailer'
end
