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
    config.encoding = 'utf-8'
    config.i18n.default_locale = :fr
    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.active_storage.draw_routes = true
    # TODO: reverto to default vips for image processing
    # this is not the default because it is slower but it avoids having to
    # install libvips which has tons of deps...
    # config.active_storage.variant_processor = :mini_magick
    config.active_storage.variant_processor = :vips

    # Custom generic app configs: everything from ENV with defaults
    # Use as Rails.configuration.key
    config.superusers = ENV.fetch('SUPERUSERS', '').split(/\s*,\s*/).select { |v| v =~ /[0-9]{6}/ }
    config.intranet_re = Regexp.new(ENV.fetch('INTRANET_RE', '^128\.17[89]'))
    config.hide_teacher_accreds = ENV.fetch('SKIP_ENS_ACCREDDS', 'true') == 'true'
    config.app_hostname = ENV.fetch('APP_HOSTNAME', 'people.epfl.ch')
    config.use_local_elements = ENV.fetch('USE_LOCAL_ELEMENTS', 'false') == 'true'
    config.enable_direct_uploads = ENV.fetch('ENABLE_DIRECT_UPLOADS', 'no') == 'true'

    # The next 3 params are just for the migration period
    # TODO: remove after migration from legacy
    config.enable_adoption = ENV.fetch('ENABLE_ADOPTION', 'false').downcase == 'true'
    config.legacy_server_url = ENV.fetch('LEGACY_SERVER_URL', 'https://personnes.epfl.ch/')
    config.legacy_pages_cache = ENV.fetch('LEGACY_PAGES_CACHE', 2.days)

    routes.default_url_options[:host] = config.app_hostname

    config.available_languages = %w[en fr]

    vf = Rails.root.join("VERSION")
    config.version = File.exist?(vf) ? File.read(vf) : "0.0.0"

    # This is a cookie-free Web app!
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
