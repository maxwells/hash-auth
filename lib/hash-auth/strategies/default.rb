module HashAuth
  module Strategies
    class Default < Base

      def self.identifier
        :default
      end

      def self.acquire_string_to_hash(controller, client)
        params = controller.params.select{|k,v| k != 'controller' && k != 'action' && k != client.signature_parameter }.map{|k,v| "#{k}=#{v}"}.join('&')
        params + client.customer_key.to_s
      end

      def self.hash_string(string)
        Digest::SHA2.new(256) << string
      end

      def self.verify_hash(target_string, client, controller)
        raise 'Parameters do not contain this client\'s signature_parameter' if controller.params[client.signature_parameter] == nil
        target_string == controller.params[client.signature_parameter]
      end

      def self.on_authentication(client, controller)
        # Do nothing
      end

      def self.on_failure(client, controller)
        controller.render :layout => false, :status => 401
      end

    end
  end
end