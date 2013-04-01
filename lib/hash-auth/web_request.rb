require 'rest-client'

module HashAuth
  class WebRequest

    def self.get(client, url, headers = {}, &block)
      self.delegate_to_rest_client_passive :get, client, url, headers, &block
    end

    def self.post(client, url, payload, headers = {}, &block)
      self.delegate_to_rest_client_active :post, client, url, payload, headers, &block
    end

    def self.patch(client, url, payload, headers = {}, &block)
      self.delegate_to_rest_client_active :post, client, url, payload, headers, &block
    end

    def self.put(client, url, payload, headers = {}, &block)
      self.delegate_to_rest_client_active :post, client, url, payload, headers, &block
    end

    def self.delete(client, url, headers = {}, &block)
      self.delegate_to_rest_client_passive :delete, client, url, headers, &block
    end

    def self.head(client, url, headers = {}, &block)
      self.delegate_to_rest_client_passive :head, client, url, headers, &block
    end

    def self.options(client, url, headers = {}, &block)
      self.delegate_to_rest_client_passive :options, client, url, headers, &block
    end

    def self.delegate_to_rest_client_passive(action, client, url, headers, &block)
      headers = self.sign_and_identify client, action, headers
      RestClient.send action, url, headers, &block
    end

    def self.delegate_to_rest_client_active(action, client, url, payload, headers, &block)
      payload = self.sign_and_identify client, action, payload
      RestClient.send action, url, payload, headers, &block
    end

    def self.sign_and_identify(client, verb, params)
      params = self.add_client_to_params(client, params)
      params = self.add_signature_to_params(client, verb, params)
      if [:get, :delete, :head, :options].include? verb
        {:params => params}
      else
        params
      end
    end

    def self.add_client_to_params(client, params)
      params[client.customer_identifier_param.to_sym] = client.customer_identifier
      params
    end

    def self.add_signature_to_params(client, verb, params)
      params[client.signature_param.to_sym] = client.strategy.sign_request(client, verb, params)
      params
    end

  end
end