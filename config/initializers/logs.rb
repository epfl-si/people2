# frozen_string_literal: true

# if defined?(LogBench)
#   LogBench.setup do |config|
#     # ... other config ...
#     config.configure_lograge_automatically = false # Don't touch my lograge config!
#   end
# end

Rails.application.configure do
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    co = { time: Time.zone.now }
    # Your custom lograge configuration
    params = event.payload[:params]&.except("controller", "action")
    co.merge!({ params: params }) if params.present?
    co
  end

  config.lograge.custom_payload do |controller|
    if controller.respond_to?(:current_user)
      {
        host: controller.request.host,
        user_id: controller.current_user&.sciper
      }
    else
      {}
    end
  end
end
