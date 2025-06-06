# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module People
  class Application < Rails::Application
    # --------------------------------------------------------- standard configs
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # ------------------------------------------------------------ local configs
    config.re_true = /^\s*(true|yes|oui|si|y+|t+)\s*$/i
    config.re_false = /^\s*(false|non?|n+|f+)\s*$/i
    config.encoding = 'utf-8'
    config.i18n.default_locale = :fr
    config.i18n.available_locales = %i[en fr]

    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.active_storage.draw_routes = true
    # TODO: reverto to default vips for image processing
    # this is not the default because it is slower but it avoids having to
    # install libvips which has tons of deps...
    # config.active_storage.variant_processor = :mini_magick
    config.active_storage.variant_processor = :vips

    # -------------------------------------------------------------
    # Custom generic app configs: everything from ENV with defaults
    # Use as Rails.configuration.KEY
    # Purely boolean values
    #    must have a default string value (e.g. 'true') and
    #    be converted to boolean with .match?(config.re_true)
    # Other values
    #    that do not have a maningfull default value should be
    #    defaulted to boolean false so thay can be safely used
    #    as flags because even an empty string is eval as true
    # -------------------------------------------------------------

    vf = Rails.root.join("VERSION")
    config.version = File.exist?(vf) ? File.read(vf) : "0.0.0"
    config.superusers = ENV.fetch('SUPERUSERS', '').split(/\s*,\s*/).select { |v| v =~ /[0-9]{6}/ }
    config.intranet_re = Regexp.new(ENV.fetch('INTRANET_RE', '^128\.17[89]'))
    config.app_hostname = ENV.fetch('APP_HOSTNAME', 'people.epfl.ch')

    config.enable_direct_uploads = ENV.fetch('ENABLE_DIRECT_UPLOADS', 'false').match?(config.re_true)
    config.use_local_elements = ENV.fetch('USE_LOCAL_ELEMENTS', 'false').match?(config.re_true)
    config.hide_teacher_accreds = ENV.fetch('HIDE_ENS_ACCREDDS', 'true').match?(config.re_true)
    config.force_audience = Rails.env.development? && ENV.fetch('FORCE_AUDIENCE', false)
    # TODO: remove next 3 lines after migration from legacy
    config.enable_adoption = ENV.fetch('ENABLE_ADOPTION', 'false').match?(config.re_true)
    config.legacy_base_url = ENV.fetch('LEGACY_BASE_URL', 'https://personnes.epfl.ch/')
    config.legacy_pages_cache = ENV.fetch('LEGACY_PAGES_CACHE', 2.days)

    # There are other ENV vars read in the yml files
    # which will probably become config maps

    # ENV vars that are read by files in environments/*.rb
    # development: REDIS_CACHE, SHOW_ERROR_PAGES
    # production: RAILS_LOG_LEVEL
    # db/seed.rb: DEV_SEEDS_PATH, SEEDS_PATH

    routes.default_url_options[:host] = config.app_hostname

    # This ~~is~~ was a cookie-free Web app!
    # Screw the EU, I don't see the difference between a cookie and an auth token.
    # config.middleware.delete ActionDispatch::Cookies
    # config.middleware.delete ActionDispatch::Session::CookieStore
    # config.session_store :disabled
    # GraphiQL::Rails.config.csrf = false if Rails.env.development?
    # config.assets.configure do |env|
    #   SprocketsRequireInGemExtension.inject_for_javascript(env)
    # end

    config.exceptions_app = routes
  end
end
