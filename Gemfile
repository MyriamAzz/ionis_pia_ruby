source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.6"
gem "appsignal"

gem "aws-sdk-s3", require: false

gem "chartkick"
gem "groupdate"

gem "render_async"

gem "trestle"
gem "trestle-auth"
gem "trestle-active_storage"
gem "image_processing", "~> 1.12", ">= 1.12.1"
# gem "avo"

gem "pdf-forms"

gem "deep_cloneable", "~> 3.0.0"
gem "rollbar"
gem "grape"
gem "grape-swagger"
gem "grape-swagger-rails"

gem "sidekiq"
gem "redis-namespace"
gem "sidekiq-cron"

gem "gocardless_pro"
gem "iban-tools"

gem "wicked_pdf"
gem "wkhtmltopdf-binary"

#Auth
gem "devise"
gem "mysql-binuuid-rails"

gem "cancancan"
gem "search_cop"
gem "cocoon"

gem "jquery-rails"
gem "rails-i18n", "~> 6.0.0"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.1", ">= 6.1.4.4"
# Use mysql as the database for Active Record
gem "mysql2", ">= 0.4.4"
# Use Puma as the app server
gem "puma", "~> 4.1"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "sprockets"
gem "sprockets-rails", :require => "sprockets/railtie"
gem "uglifier"
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

group :development, :test do
  gem "rufo"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "faker", :git => "https://github.com/faker-ruby/faker.git", :branch => "master"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "rubocop", require: false
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.2"
  gem "ngrok-tunnel"
  gem "tty-box"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "letter_opener"
  gem "letter_opener_web", "~> 1.0"

  gem "capistrano", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano3-puma", require: false
  gem "capistrano-rails-collection", require: false
  gem "capistrano-rails-db", require: false
  gem "capistrano-ssh-doctor", require: false
  gem "capistrano-faster-assets", require: false
  gem "capistrano-webpacker-precompile", require: false
  gem "capistrano-sidekiq"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
