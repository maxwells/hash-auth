require 'digest'

module HashAuth
  module Strategies
    class Base
      # provide the HashAuth system with a handle for this strategy
      def self.identifier
        raise "identifier method not implemented in #{self.class.name}"
      end

      # upon receiving a hashed request, extract the string that needs to be hashed and compared to the signature passed
      def self.acquire_string_to_hash(controller, client)
        raise "acquire_string_to_hash method not implemented in #{self.class.name}"
      end

      # how the querystring should be hashed (eg. hmac-sha1, md5)
      def self.hash_string(client, string)
        raise "hash_string method not implemented in #{self.class.name}"
      end

      # determine equality of the target string, as calculated by acquire_string_to_hash -> hash_string, with the actual signature passed by client
      def self.verify_hash(target_string, client, controller)
        raise "verify_hash method not implemented in #{self.class.name}"
      end

      # anything special that needs to be done upon successful authentication of a request (eg. log in proxy user for a given client)
      def self.on_authentication(client, controller)
        raise "on_authentication method not implemented in #{self.class.name}"
      end

      # on_failure is triggered during the before_filter of an action that requires hash authentication
      # if any of the cases are met (these are the options for type):
      #  - :no_matching_client
      #  - :invalid_domain
      #  - :invalid_hash
      def self.on_failure(client, controller, type)
        raise "on_failure method not implemented in #{self.class.name}"
      end

      # sign_request should sign the outgoing request. Given the different objects available at request
      # creation time versus receipt time, this method needs to be included in addition to acquire_string_to_hash
      def self.sign_request(client, verb, params)
        raise "sign_request method not implemented in #{self.class.name}"
      end
    end
  end
end