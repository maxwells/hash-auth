source "http://rubygems.org"

# Declare your gem's dependencies in hash-auth.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem "rspec-rails", :group => [:test, :development]
group :test do
  gem 'metric_fu'
  gem "capybara"
  gem "guard-rspec"
  gem 'guard'
  gem 'guard-bundler'
  gem "rb-fsevent"
  gem "activerecord"
  if RUBY_PLATFORM.downcase.include?("darwin")
    gem 'ruby_gntp'
    gem 'growl' # also install growlnotify from the Extras/growlnotify/growlnotify.pkg in Growl disk image.
  end
end
