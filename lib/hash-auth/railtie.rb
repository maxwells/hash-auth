require 'active_record/railtie'
require 'action_controller'

module HashAuth
  class Railtie < Rails::Railtie
    if defined?(ActionController::Base)
      ActionController::Base.send :include, HashAuth
    end
  end
end