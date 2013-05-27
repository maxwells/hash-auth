module HashAuth
  module Strategies
    class Default < Base

      def self.identifier
        :default
      end

      def self.acquire_string_to_hash(controller, client)
        params = controller.params.select{|k,v| !['controller', 'action', 'format', client.signature_param].include? k }.map{|k,v| "#{k}=#{v}"}.join('&')
        params + client.customer_key.to_s
      end

      def self.hash_string(client, string)
        digest = Digest::SHA256.new
        digest.hexdigest string
      end

      def self.verify_hash(target_string, client, controller)
        return false if controller.params[client.signature_param] == nil
        target_string == controller.params[client.signature_param]
      end

      def self.on_authentication(client, controller)
        # Do nothing
      end

      def self.on_failure(client, controller, type)
        case type
        when :no_matching_client
          controller.instance_variable_set '@failure_message', 'Not a valid client'
        when :invalid_domain
          controller.instance_variable_set '@failure_message', 'Request coming from invalid domain'
        when :invalid_hash
          controller.instance_variable_set '@failure_message', 'Signature hash is invalid'
        when :invalid_ip
          controller.instance_variable_set '@failure_message', 'Request coming from invalid IP' 
        end
      end

      def self.sign_request(client, verb, params)
        self.hash_string(client, params.map{|k,v| "#{k}=#{v}"}.join('&') + client.customer_key.to_s)
      end

    end
  end
end