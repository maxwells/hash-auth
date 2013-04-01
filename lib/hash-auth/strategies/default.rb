module HashAuth
  module Strategies
    class Default < Base

      def self.identifier
        :default
      end

      def self.acquire_string_to_hash(controller, client)
        params = controller.params.select{|k,v| k != 'controller' && k != 'action' && k != client.signature_param }.map{|k,v| "#{k}=#{v}"}.join('&')
        params + client.customer_key.to_s
      end

      def self.hash_string(client, string)
        Digest::SHA2.new(256) << string
      end

      def self.verify_hash(target_string, client, controller)
        return false if controller.params[client.signature_param] == nil
        target_string == controller.params[client.signature_param]
      end

      def self.on_authentication(client, controller)
        # Do nothing
      end

      def self.on_failure(client, controller, type)
        controller.instance_variable_set '@failure_message', 'Not a valid client' if type == :no_matching_client
        controller.instance_variable_set '@failure_message', 'Request coming from invalid domain' if type == :invalid_domain
        controller.instance_variable_set '@failure_message', 'Signature hash is invalid' if type == :invalid_hash
      end

      def self.sign_request(client, verb, params)
        self.hash_string(client, params.map{|k,v| "#{k}=#{v}"}.join('&') + client.customer_key.to_s)
      end

    end
  end
end