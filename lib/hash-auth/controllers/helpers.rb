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
        string_to_hash = HashAuth.configuration.acquire_string_to_hash.call self
        client = HashAuth::ClientIp.find_by_address(request.remote_ip).client
        target_string = HashAuth.confiuration.hash_string string_to_hash, client
        authenticated = (target_string == params[client.ext_id_field.to_sym])
        puts "#{string_to_hash} was #{authenticated ? 'successfully' : 'not'} authenticated for the given client"
      end

      def extract_client_from_request
        # EITHER create a join table and rules for what ip addresses and what not are valid and match up with the request initiating ip
        # OR get list of ext_id_fields for clients, match them with params, and match where ext_id = params[:ext_id_field] for a given client
      end
    end
  end
end
