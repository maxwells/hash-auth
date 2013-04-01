require 'rest-client'

module HashAuth
  class WebRequest

    def self.get(client, url, headers = {}, &block)
      headers = self.sign_and_identify client, :get, headers
      RestClient.get url, headers, &block
    end

    def self.post(client, url, payload, headers = {}, &block)
      payload = self.sign_and_identify client, :post, payload
      RestClient.post url, payload, headers, &block
    end

    def self.patch(client, url, payload, headers = {}, &block)
      payload = self.sign_and_identify client, :patch, payload
      RestClient.patch url, payload, headers, &block
    end

    def self.put(client, url, payload, headers = {}, &block)
      headers = self.sign_and_identify client, :put, headers
      RestClient.put url, payload, headers, &block
    end

    def self.delete(client, url, headers = {}, &block)
      headers = self.sign_and_identify client, :delete, headers
      RestClient.delete url, headers, &block
    end

    def self.head(client, url, headers = {}, &block)
      headers = self.sign_and_identify client, :head, headers
    end

    def self.options(client, url, headers = {}, &block)
      headers = self.sign_and_identify client, :options, headers
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