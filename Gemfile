source 'https://rubygems.org'

ruby '2.1.2'

gem 'airbrake'
gem 'bourbon', '~> 3.2.1'
gem 'coffee-rails'
gem 'delayed_job_active_record'
gem 'draper'
gem 'email_validator'
gem 'flutie'
gem 'hashids', '~> 0.3.0'
gem 'high_voltage'
gem 'jbuilder', '~> 2.1.1'
gem 'jquery-rails'
gem 'json_spec', '~> 1.1.2'
gem 'neat', '~> 1.5.1'
gem 'oj', '~> 2.9.6'
gem 'oj_mimic_json', '~> 1.0.1'
gem 'paperclip', '~> 4.1.1'
gem 'phony_rails', '~> 0.6.1'
gem 'pg'
gem 'rack-timeout'
gem 'rails', '4.1.1'
gem 'recipient_interceptor'
gem 'sass-rails', '~> 4.0.3'
gem 'simple_form'
gem 'title'
gem 'twilio-ruby'
gem 'uglifier'
gem 'unicorn'

group :development do
  gem 'foreman'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development, :test do
  gem 'awesome_print'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 2.14.0'
end

group :test do
  gem 'capybara-webkit', '>= 1.0.0'
  gem 'database_cleaner'
  gem 'formulaic'
  gem 'launchy'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
end

group :staging, :production do
  gem 'rails_12factor'
  gem 'newrelic_rpm', '>= 3.7.3'
end
