require 'rails/all'
require 'active_support/all'
require 'action_controller/railtie'
require 'hash-auth'
require 'rails-helpers'
require File.expand_path('../../test/dummy/spec/spec_helper', __FILE__)
require File.expand_path('../../test/dummy/spec/controllers/helper_spec', __FILE__)
RSpec.configure do |config|
  config.order = "random"
end