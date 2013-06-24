require 'resolv'

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

        case HashAuth.configuration.domain_auth
        when :ip
          return @client.strategy.on_failure(@client, self, :invalid_ip) unless check_ip(request.remote_ip)
        when :reverse_dns
          domain = extract_domain(request.remote_ip)
          return @client.strategy.on_failure(@client, self, :invalid_domain) unless check_host(domain)
        end

        string_to_hash = @client.strategy.acquire_string_to_hash self, @client
        target_string = @client.strategy.hash_string @client, string_to_hash
        @authenticated = @client.strategy.verify_hash(target_string, @client, self)

        return @client.strategy.on_authentication @client, self if @authenticated
        @client.strategy.on_failure(@client, self, :invalid_hash)
      end

      def extract_client_from_request
        HashAuth.clients.each do |c|
          return c if params[c.customer_identifier_param] == c.customer_identifier
        end
        nil
      end

      def extract_domain(ip)
        cache_address = "#{HashAuth.configuration.cache_store_namespace}-#{ip}"
        cached_result = Rails.cache.read cache_address
        return cached_result unless cached_result == nil
        hostname = Resolv.new.getname(ip)
        Rails.cache.write cache_address, hostname
        hostname
      end

      def check_ip(ip)
        return true if @client.valid_ips.length == 0
        @client.valid_ips.each do |valid_ip|
          match = regexp_from_string(valid_ip).match(ip)
          return true if match != nil
        end
        false
      end

      def check_host(host)
        return true if @client.valid_domains.length == 0
        @client.valid_domains.each do |d|
          match = regexp_from_string(d).match(host)
          return true if match != nil
        end
        false
      end

      def regexp_from_string(host)
        Regexp.new '^'+host.gsub('.','\.').gsub('*', '.*') + '$'
      end

    end
  end
end
