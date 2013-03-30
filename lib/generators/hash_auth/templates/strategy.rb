module HashAuth
  module Strategies
    class <%= class_name %> < Base

      def self.identifier
        :<%= file_name %> # name of strategy (symbol)
      end

      def self.acquire_string_to_hash(controller, client)
        # returns the string to hash to authenticate
      end

      def self.hash_string(string)

      end

      def self.verify_hash(target_string, client, controller)
        # verify hashed string against agreed upon parameter or request header
      end

      def self.on_authentication(client, controller)
        # do something, if applicable
      end

      def self.on_failure(client, controller)
        raise "on_failure method not implemented in #{self.class.name}"
      end
      
    end
  end
end