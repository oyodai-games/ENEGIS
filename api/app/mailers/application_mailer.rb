# frozen_string_literal: true

# ApplicationMailer is the base class for all mailers in the application.
# It provides common settings such as the default sender email and layout.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
