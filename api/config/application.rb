# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# The Api module serves as the namespace for the API-related classes.
module Api
  # Api::Application is the main application class for the API.
  # It inherits from Rails::Application and handles configuration settings for the API.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # chatGPT config
    config.chatgpt_generate_text = config_for(:chatgpt_generate_text)

    # servicesディレクトリをオートロードパスに追加
    config.autoload_paths += %W[#{config.root}/api/app/services]
  end
end
