# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # For this we can use the Env vari RAILS_DEVELOPMENT_HOSTS
  # config.hosts << "2.tcp.eu.ngrok.io"

  # Allow web console also from outside localhost (for using it with docker)
  config.web_console.permissions = '0.0.0.0/0'

  config.skip_api_access_control = ENV.fetch('SKIP_API_ACCESS_CONTROL', "false").match?(config.re_true)

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  case ENV.fetch('ERROR_PAGES', 'mix')
  when 'prod'
    config.consider_all_requests_local = false
  when 'dev'
    # Show full error reports (including 404s)
    config.consider_all_requests_local = true
  else
    # Show full error reports only for 500s
    config.consider_all_requests_local = false
    config.x.dwim_error_pages = true
  end

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }

    config.cache_store = if ENV['REDIS_CACHE'].present? && !ENV['REDIS_CACHE'].match?(config.re_false)
                           [:redis_cache_store, {
                             url: ENV['REDIS_CACHE'],
                             connect_timeout: 10, # Defaults to 20 seconds
                             read_timeout: 0.2, # Defaults to 1 second
                             write_timeout: 0.2, # Defaults to 1 second
                             reconnect_attempts: 1 # Defaults to 0
                           }]
                         else
                           :memory_store
                         end
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Log to stdout and file to be closer to prod
  stdout_logger = ActiveSupport::Logger.new($stdout)
  if (lfb = ENV.fetch('LOGFILE', '')).present?
    # lf is the basename. We attach a pod unique identifier to avoid overlaps
    lfe = `hostname`.chomp.split("-").last
    file_logger = ActiveSupport::Logger.new("#{lfb}_#{lfe}.log")
    config.logger = ActiveSupport::BroadcastLogger.new(stdout_logger, file_logger)
  else
    config.logger = stdout_logger
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = false

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Configure Solid Errors
  config.solid_errors.base_controller_class = "Admin::BaseController"
  config.solid_errors.connects_to = { database: { writing: :errors } }
  config.solid_errors.send_emails = true
  config.solid_errors.email_from = "noreply@epfl.ch"
  config.solid_errors.email_to = "fake@gmail.com"
  # config.solid_errors.username = Rails.application.credentials.dig(:solid_errors, :username)
  # config.solid_errors.password = Rails.application.credentials.dig(:solid_errors, :password)
end
