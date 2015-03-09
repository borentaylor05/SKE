source 'https://rubygems.org'

gem 'rails',                '4.2.0.rc1'
gem 'sass-rails'           
gem 'uglifier',             '2.5.3'
#gem 'coffee-rails',         '4.0.1'
gem 'jquery-rails'        
gem 'turbolinks',           '2.3.0'
gem 'jbuilder',             '2.2.3'
gem 'rails-html-sanitizer', '1.0.1'
gem 'sdoc',                 '0.4.0', group: :doc
gem 'ruby'
gem 'unicorn'
gem 'pg',             '0.17.1'
gem 'newrelic_rpm'
gem 'httparty'
gem 'twitter'
gem 'bootstrap-sass',       '3.2.0.0'
gem "sinatra"
gem "omniauth-salesforce"
gem "thin"
gem 'restforce'
gem 'activerecord-session_store'
gem 'devise'
gem "font-awesome-rails"
gem 'jquery-turbolinks'     # to prevent having to refresh to load js 
gem 'rack-cors', :require => 'rack/cors'

group :development, :test do
  gem 'byebug',      '3.4.0'
  gem 'web-console' 
  gem 'spring',      '1.1.3'
  gem 'faker', '~> 1.3.0'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
end

group :test do
  gem 'minitest-reporters', '1.0.5'
  gem 'mini_backtrace',     '0.1.3'
  gem 'guard-minitest',     '2.3.1'
end

group :production do
  gem 'rails_12factor', '0.0.2'
  gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
  gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
end