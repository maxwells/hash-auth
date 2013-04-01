module HashAuth
  module Strategies
    class New < Base

      def name
        :new # name of strategy (symbol)
      end

      def acquire_string_to_hash(controller, client)
        # returns the string to hash to authenticate
      end

      def hash_string(string)

      end

      def verify_hash(target_string, client, controller)
        # verify hashed string against agreed upon parameter or request header
      end

      def on_authentication(client, controller)
        # do something, if applicable
      end

    end
  end
end