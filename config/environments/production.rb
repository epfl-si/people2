# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Caching is turned on.
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # We use 12 factor => config via env variables
  config.require_master_key = false

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # A more compact log to stdout and the usual one to file
  # stdout_logger = ActiveSupport::TaggedLogging.logger.new($stdout)
  stdout_logger = ActiveSupport::Logger.new($stdout)
  if (lfb = ENV.fetch('LOGFILE', '')).present?
    max_log_size = ENV.fetch('LOGSIZE', 128).to_i * 1024 * 1024
    log_rotate_count = ENV.fetch('LOGROTATE', 8).to_i
    # lf is the basename. We attach a pod unique identifier to avoid overlaps
    lfe = `hostname`.chomp.split("-").last
    file_logger = ActiveSupport::Logger.new("#{lfb}_#{lfe}.log", log_rotate_count, max_log_size)
    config.logger = ActiveSupport::BroadcastLogger.new(stdout_logger, file_logger)
  else
    config.logger = stdout_logger
  end

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  if ENV['REDIS_CACHE'].present? && !ENV['REDIS_CACHE'].match?(config.re_false)
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_CACHE'],
      connect_timeout: 10, # Defaults to 20 seconds
      read_timeout: 0.2, # Defaults to 1 second
      write_timeout: 0.2, # Defaults to 1 second
      reconnect_attempts: 1 # Defaults to 0
    }
  end

  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "people2024_production"

  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    address: "mail.epfl.ch",
    port: 25,
    domain: "epfl.ch",
    enable_starttls: false,
    open_timeout: 5,
    read_timeout: 5
  }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true
  # config.i18n.fallbacks = [:en]
  # I18n.enforce_available_locales = false

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  # if ENV['RAILS_LOG_TO_STDOUT'].present?
  #   logger           = ActiveSupport::Logger.new($stdout)
  #   logger.formatter = config.log_formatter
  #   config.logger    = ActiveSupport::TaggedLogging.new(logger)
  # end

  # Configure Solid Errors
  config.solid_errors.base_controller_class = "Admin::BaseController"
  config.solid_errors.connects_to = { database: { writing: :errors } }
  config.solid_errors.send_emails = false
  # config.solid_errors.email_from = ""
  # config.solid_errors.email_to = ""
  # config.solid_errors.username = Rails.application.credentials.dig(:solid_errors, :username)
  # config.solid_errors.password = Rails.application.credentials.dig(:solid_errors, :password)
end
