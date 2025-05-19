# frozen_string_literal: true

# https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://web2018.epfl.ch/'
    resource '*', headers: :any, methods: %i[get]
  end
end
