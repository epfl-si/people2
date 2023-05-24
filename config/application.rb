require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HelloRails
  class Application < Rails::Application

    config.encoding = "utf-8"

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.assets.configure do |env|
      SprocketsRequireInGemExtension::inject_for_javascript(env)
    end

    # config.middleware.use Rack::Locale

    # This is a cookie-free Web app!
    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Session::CookieStore
    config.session_store :disabled
    if Rails.env.development?
      GraphiQL::Rails.config.csrf = false
    end

    # config.generators do |g|
    #   g.helper false
    #   g.assets false
    # end

    # Custom app configs: everything from ENV with defaults
    # Use as Rails.configuration.key
    config.prefer_atela = ENV.fetch("PREFER_ATELA", false)
    config.atela_backend_url = ENV.fetch("ATELA_BACKEND_URL", 'https://atela.epfl.ch/cgi-bin/atela-backend')
    config.isa_url = ENV.fetch("ISA_URL", 'https://isa.epfl.ch/services')
    config.isa_no_check_ssl = ENV.fetch("ISA_NO_CHECK_SSL", false)
    config.intranet_re = Regexp.new(ENV.fetch("INTRANET_RE", '^128\.17[89]'))
    config.official_url = ENV.fetch("OFFICIAL_URL", "https://people.epfl.ch")
    config.isa_use_oracle = ENV.fetch("ISA_USE_ORACLE", true)

  end
end
