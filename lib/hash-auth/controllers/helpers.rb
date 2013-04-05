module HashAuth
  module Controllers
    module Helpers
    extend ActiveSupport::Concern

      module ClassMethods
        def initialize_for_hash_auth(actions_requiring_hash_verification)
          if actions_requiring_hash_verification = [:all]
            before_filter :verify_hash
          else
            before_filter :verify_hash, :only => actions_requiring_hash_verification
          end
        end
      end

      protected 
      def verify_hash
        @client = extract_client_from_request
        return HashAuth.configuration.default_strategy.on_failure(nil, self, :no_matching_client) unless @client

        valid_domain = check_host(request.host)
        return @client.strategy.on_failure(@client, self, :invalid_domain) unless valid_domain

        string_to_hash = @client.strategy.acquire_string_to_hash self, @client
        target_string = @client.strategy.hash_string @client, string_to_hash
        @authenticated = @client.strategy.verify_hash(target_string, @client, self) && valid_domain
        
        if @authenticated
          @client.strategy.on_authentication @client, self
        else
          @client.strategy.on_failure(@client, self, :invalid_hash)
        end
      end

      def extract_client_from_request
        HashAuth.clients.each do |c|
          return c if params[c.customer_identifier_param] == c.customer_identifier
        end
        nil
      end

      def check_host(host)
        @client.valid_domains.each do |d|
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
