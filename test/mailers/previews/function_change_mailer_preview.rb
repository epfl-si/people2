# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/function_change_mailer
class FunctionChangeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/function_change_mailer/accreditor_request
  delegate :accreditor_request, to: :FunctionChangeMailer
end
