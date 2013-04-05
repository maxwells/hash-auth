require 'digest'

module HashAuth
  module Strategies
    class ReverseGuid < Base
      # provide the HashAuth system with a handle for this strategy
      def self.identifier
        :reverse_guid
      end

      # upon receiving a hashed request, extract the string that needs to be hashed and compared to the signature passed
      def self.acquire_string_to_hash(controller, client)
        initial_query = controller.params.select{|k,v| not %W[action controller source #{client.signature_param}].include? k.to_s} # exclude rails parameters and signature parameter
        initial_query['guid'] = initial_query['guid'].to_s.reverse
        string = initial_query.map{|k,v| "#{k}=#{v}"}.join('&') + client.customer_key.to_s # form query_string and append customer key 
        string
      end

      # how the querystring should be hashed (eg. hmac-sha1, md5)
      def self.hash_string(client, string)
        Digest::SHA2.new(256) << string
      end

      # determine equality of the target string, as calculated by acquire_string_to_hash -> hash_string, with the actual signature passed by client
      def self.verify_hash(target_string, client, controller)
        return false if controller.params[client.signature_param] == nil
        target_string == controller.params[client.signature_param]
      end

      # anything special that needs to be done upon successful authentication of a request (eg. log in proxy user for a given client)
      def self.on_authentication(client, controller)
        # do nothing
      end

      # on_failure is triggered during the before_filter of an action that requires hash authentication
      # if any of the cases are met (these are the options for type):
      #  - :no_matching_client
      #  - :invalid_domain
      #  - :invalid_hash
      def self.on_failure(client, controller, type)
        controller.instance_variable_set '@failure_message', 'Not a valid client' if type == :no_matching_client
        controller.instance_variable_set '@failure_message', 'Request coming from invalid domain' if type == :invalid_domain
        controller.instance_variable_set '@failure_message', 'Signature hash is invalid' if type == :invalid_hash
      end

      # sign_request should sign the outgoing request. Given the different objects available at request
      # creation time versus receipt time, this method needs to be included in addition to acquire_string_to_hash
      def self.sign_request(client, verb, params)
        params[:guid] = rand.to_s[2..15]
        self.hash_string(client, params.each{|k,v| v = v.reverse if k == :guid}.map{|k,v| "#{k}=#{v}"}.join('&') + client.customer_key.to_s)
      end
    end
  end
end