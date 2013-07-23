source 'http://rubygems.org'

gem 'rails', '3.1.0'

gem 'haml'

# Google
gem "omniauth-google-oauth2"
gem 'google-api-client'

# assets
gem 'therubyracer'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'less-rails'
gem 'less-rails-bootstrap'
gem "font-awesome-rails"

# JSON server
gem 'rabl'
gem 'oj'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

group :development, :test do
  gem 'sqlite3'
  gem 'ruby-debug19' # remove when upgrading to Ruby 2.0d
  gem 'pry'
end

group :production do
  gem 'pg' # use PostgreSQL in production (Heroku)
  gem 'pry-rails'
end

group :development do
  gem 'disable_assets_logger'
  gem 'pry-rails'
end

group :test do
  gem 'cucumber-rails'
  gem 'cucumber-rails-training-wheels' # some pre-fabbed step definitions  
  gem 'database_cleaner'               # to clear Cucumber's test database between runs
  gem 'capybara', "~> 2.0.3"           # lets Cucumber pretend to be a web browser
  gem 'launchy'                        # a useful debugging aid for user stories
end
