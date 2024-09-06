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
    config.active_storage.draw_routes = true
    # TODO: reverto to default vips for image processing
    # this is not the default because it is slower but it avoids having to
    # install libvips which has tons of deps...
    # config.active_storage.variant_processor = :mini_magick

    # Custom generic app configs: everything from ENV with defaults
    # Use as Rails.configuration.key
    config.admin_scipers = ENV.fetch('ADMIN_SCIPERS', '').split(/\s*,\s*/).select { |v| v =~ /[0-9]{6}/ }
    config.intranet_re = Regexp.new(ENV.fetch('INTRANET_RE', '^128\.17[89]'))
    config.hide_teacher_accreds = ENV.fetch('SKIP_ENS_ACCREDDS', true)
    config.app_hostname = ENV.fetch('APP_HOSTNAME', 'people.epfl.ch')
    routes.default_url_options[:host] = config.app_hostname

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
