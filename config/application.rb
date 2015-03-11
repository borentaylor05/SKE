require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'
require 'rack/cors'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SKE
  class Application < Rails::Application

    config.middleware.insert 0, Rack::Cors do
        allow do
            origins 'social.teletech.com'

            resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
        end

        allow do
            origins '*'

            resource '/maintainers/*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource '/fx/tickets', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource '/cdc/api/topic', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/cdc/upload/address-book", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/cdc/process/address-book", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/cdc/upload/a-to-z", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/cdc/process/a-to-z", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/cdc/a-to-z", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/cdc/change/a-to-z", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/deadlines/edit", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/deadline/save", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/upload/classifications", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/process/classifications", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/upload/deadlines", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/process/deadlines", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/fx/request-article", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/temp/upload", :headers => :any, :methods => [:get, :post, :put, :delete, :options]
            resource "/temp/upload/process", :headers => :any, :methods => [:get, :post, :put, :delete, :options]

        end

    end

    # Settings in config/environments/* take precedence overthosespecified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
  #  config.serve_static_assets = true # Rails 4 serve assets
    config.autoload_paths += %W(#{config.root}/lib) # add this line
    config.active_record.raise_in_transactional_callbacks = true
    config.generators do |g|
        g.test_framework :rspec
    end
  end
end
