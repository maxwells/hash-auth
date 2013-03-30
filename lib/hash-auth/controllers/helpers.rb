module HashAuth
  module Controllers
    module Helpers
    extend ActiveSupport::Concern

      included do
        "HashAuth::Controllers::Helpers Included"        
      end
      module ClassMethods

        def initialize_for_hash_auth(actions_requiring_hash_verification)
          puts "initialize_with_hash called"
          before_filter :verify_hash, :only => actions_requiring_hash_verification
        end

      end

      protected 
      def verify_hash
        ###
        ###
        ### I am seeing a need to provide specific failure methods (no client, client domain failed, authentication failed)
        ###
        ###

        client = extract_client_from_request
        return client.strategy.on_failure(nil, self) unless client

        valid_domain = check_host(client, request.host)
        return client.strategy.on_failure(client, self) unless valid_domain

        string_to_hash = client.strategy.acquire_string_to_hash self, client
        target_string = client.strategy.hash_string string_to_hash
        authenticated = client.strategy.verify_hash(target_string, client, self) && valid_domain
        return client.strategy.on_failure(client, self) unless authenticated
      end

      def extract_client_from_request
        HashAuth.clients.each do |c|
          return c if params[c.customer_identifier_param] == c.customer_identifier
        end
        raise "No client matches the request"
      end

      def check_host(client, host)
        client.valid_domains.each do |d|
          match = regexp_from_host(d).match(host)
          return true if match != nil
        end
        false
      end

      def regexp_from_host(host)
        Regexp.new '^'+host.gsub('.','\.').gsub('*', '.*') + '$'
      end

    end
  end
end
