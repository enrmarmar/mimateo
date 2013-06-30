source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'omniauth-twitter'
gem "omniauth-google-oauth2"




# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
  gem 'therubyracer'
  gem 'less-rails'
  gem 'less-rails-bootstrap'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
end



# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

gem 'haml'

group :development, :test do
  gem 'sqlite3'
  gem 'ruby-debug19'
end

group :production do
  gem 'pg' # use PostgreSQL in production (Heroku)
end
