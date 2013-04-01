require 'rails'
require 'active_support/all'
require 'action_controller/railtie'
require 'hash-auth'
require 'fake-rails-app'
RSpec.configure do |config|
  config.order = "random"
end