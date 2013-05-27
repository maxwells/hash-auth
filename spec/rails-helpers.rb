#### Faking a rails application that is configured with HashAuth for spec purposes

class OnFailureError < Exception
end

module HashAuth
  module Strategies
    class New < Base

      def self.identifier
        :new
      end

      def self.acquire_string_to_hash(controller, client)
        controller.params.select{|k,v| k != 'controller' && k != 'action' && k != client.signature_parameter }.map{|k,v| "#{k}=#{v}"}.join('&')
      end

      def self.hash_string(client, string)
        Digest::MD5.digest string
      end

      def self.verify_hash(target_string, client, controller)
        raise 'Parameters do not contain this client\'s signature_parameter' if controller.params[client.signature_parameter] == nil
        target_string == controller.params[client.signature_parameter]
      end

      def self.on_authentication(client, controller)
        # Do nothing
      end

      def self.on_failure(client, controller, type)
        raise OnFailureError, "Failure to authenticate"
        # Do nothingå
      end

    end
  end
end

# clients = [
#   {
#     :customer_key => 1234567890,
#     :customer_identifier => 'my_organization',
#     :customer_identifier_param => 'customer_id',
#     :valid_domains => 'localhost',
#     :strategy => :default
#   },
#   {
#     :customer_key => 987654321,
#     :customer_identifier => 'your_organization',
#     :customer_identifier_param => 'customer_id',
#     :valid_domains => ['*google.com', '*.org'],
#     :strategy => :default
#   },
#   {
#     :customer_key => 'zyxwvut',
#     :customer_identifier => 'test',
#     :valid_domains => '*',
#     :strategy => :new
#   },
#   {
#     :customer_key => 9988776655,
#     :customer_identifier => 'no_matching_client',
#     :customer_identifier_param => 'customer_id',
#     :valid_domains => 'localhost',
#     :strategy => :default
#   },
#   {
#     :customer_key => 'something other than will be on server',
#     :customer_identifier => 'incorrect_hash',
#     :customer_identifier_param => 'customer_id',
#     :valid_domains => 'localhost',
#     :strategy => :default
#   }
# ]

# Faking controller/action requests
class RequestHelper

  def self.parse_params(string)
    h = {}
    s = string.split('&').map{|set| set.split '=' }.each do |p|
      h[p[0]] = p[1]
    end
    h
  end

  def initialize(hash)
    hash.each do |key,value|
      add_instance_getters_and_setters key
      send "#{key}=", value
    end
  end

  # Add instance specific getters and setters for the name passed in,
  # so as to allow different Client objects to have different properties
  # that are accessible by . notation
  def add_instance_getters_and_setters(var)
    singleton = (class << self; self end)
    singleton.send :define_method, var.to_sym do
      instance_variable_get "@#{var}"
    end
    singleton.send :define_method, "#{var}=".to_sym do |val|
      instance_variable_set "@#{var}", val
    end
  end

end