require 'digest'

module HashAuth
  module Strategies
    class Base
      def self.identifier
        raise "identifier method not implemented in #{self.class.name}"
      end

      def self.acquire_string_to_hash(controller, client)
        raise "acquire_string_to_hash method not implemented in #{self.class.name}"
      end

      def self.hash_string(string)
        raise "hash_string method not implemented in #{self.class.name}"
      end

      def self.verify_hash(target_string, client, controller)
        raise "verify_hash method not implemented in #{self.class.name}"
      end

      def self.on_authentication(client, controller)
        raise "on_authentication method not implemented in #{self.class.name}"
      end

      def self.on_failure(client, controller)
        raise "on_failure method not implemented in #{self.class.name}"
      end
    end
  end
end