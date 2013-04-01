require 'hash-auth/config'

module HashAuth
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  included do
    #puts "HashAuth included"
  end
  autoload :Controllers, 'hash-auth/controllers'
  autoload :Strategies, 'hash-auth/strategies'
  autoload :Client, 'hash-auth/client'
  autoload :WebRequest, 'hash-auth/web_request'

  module ClassMethods
    def validates_auth_for(*methods, &block)
      self.send :include, Controllers::Helpers
      initialize_for_hash_auth methods
    end
  end

  def self.configured?
    @config.present?
  end
end

require 'hash-auth/railtie'