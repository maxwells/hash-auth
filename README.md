# HashAuth
[![Code Climate](https://codeclimate.com/github/maxwells/hash-auth.png)](https://codeclimate.com/github/maxwells/hash-auth)
[![Dependency Status](https://gemnasium.com/maxwells/hash-auth.png)](https://gemnasium.com/maxwells/hash-auth)
[![Build Status](https://travis-ci.org/maxwells/hash-auth.png?branch=master)](https://travis-ci.org/maxwells/hash-auth)

HashAuth allows your Rails application to support incoming and outgoing two-factor authentication via hashing some component of an HTTPS request. Both sides of the request (your Rails app and your client or provider) must have some unique shared secret. This secret is used to create a hash of some portion of the request, ensuring that (if neither side has been compromised) only the other party could have created the request.

Solely using a shared key leaves one hole open: the ability for a third party to send a duplicate request if they are playing man in the middle, so it is important to combine the secret key with some unique data (eg. request IP and datetime) to reduce the scope of when and from where a given request is valid. Again, this only applies to duplicate requests.

_Note: Only Ruby 1.9.2 and above are supported, due to lack of ordered Hash objects in previous versions._

## Features
- HashAuth can be configured to support multiple clients, each with their own authentication blocks (ie. customer 1 could use MD5 hash, customer 2 could use hmac-SHA256).
- Clients can be authenticated as a proxy user upon successful hash authentication (ie. if your controller action depends on having current_user, you can assign an email address to your client and have it log in that user)
- Custom blocks can be provided to (a) acquire the string to hash, (b) hash the string, or (c) perform a custom action upon authentication from a request from each indivudual client
- Enhanced security can be enabled by requiring each client to submit a GMT version of their system time to be included in the hash, which will mean any given request is only valid within a predefined window (reduces the possibility of a man in the middle attack through duplicate requests)
- Requests can be filtered by remote ip address specifically or by the reverse dns lookup of the remote ip address

## Usage

### Installation

1) Install the HashAuth gem from RubyGems

	$ gem install hash-auth

2) Add it to your Rails application's Gemfile

	gem "hash-auth"
	
3) Install it into your Rails application

	$ rails g hashauth:install	
	
4) If you need to create your own strategies

	$ rails g hashauth:strategy [name]

### Configuration

The install generator will place an initializer (hashauth.rb) into your config/initializers directory. The following will walk you through the default configuration options and what they mean


**_Adding an authentication strategy._**

Generate a new strategy, which will live in lib/hash_auth/strategies

	rails g hash_auth:strategy name_of_strategy

This will generate a template that needs to be filled in with the necessary behavior for authenticating your client. Here is an example strategy


```ruby	

	module HashAuth
      module Strategies
        class NameOfStrategy < Base

          def name
            :name_of_strategy
          end

		  ## The string that your client hashes for its signature is a concatenation of parameters in order, joined by '&' and appended with the client's secret key.
          def acquire_string_to_hash(controller, client)
            controller.params.select{|k,v| k != 'controller' && k != 'action' }.map{|k,v| "#{k}=#{v}"}.join('&') + client.customer_key
          end

		  # Client hashes string with SHA256
          def hash_string(string, client)
            Digest::sha2.new(256) << string
          end

          def on_authentication(client)
            # Do nothing. If you were so inclined, you could use the client information to do something specific to your system (like logging in a proxy user for your API client with your favorite user management system)
          end

        end
      end
    end

```

**_Adding Clients via hardcoding (Config)._**


```ruby

	#### Adding a new client
	
	# Add a client to a strategy. Any key:value sets can be added to the hash, which will be accessible in your strategy. The required ones are shown below (though there are default options for customer_identifier_param and strategy)
	add_client {
		:customer_key => '1234567890',
			# the shared secret between you and a client
		:customer_identifier => 'my_organization',
			# the unique identifer the client will pass you to identify themselves
		:customer_identifier_param => 'customer_id',
			# the name of the parameter the client will pass their unique identifier in
		:valid_domains => '*my_organization.org',
			# will allow request from anything ending with my_organization.org, can also provide a list. Note: this only works if reverse_dns ip filtering, so the reverse dns lookup for a clients IP must match up. (domain_auth :reverse_dns)
		:valid_ips => '192.168.1.1',
			# will allow request from a specific ip or list of ips. Note: only works if ip filtering is enabled (domain_auth :ip)
		:strategy => :my_auth_strategy,
			# If no strategy is provided, then the default (HashAuth::Strategies::Default) will be used. If the strategy symbol does not reference a valid strategy, then an exception will be raised
	}
```
**_Adding Clients from an external resource (eg YAML, Database)._**
		
YAML file (config/clients.yml in this example):

	clients:
      -
        customer_key: 1234567890
        customer_identifier: my_organization
        customer_identifier_param: customer_id
        valid_domains: '*my_organization.org'
        valid_ips: '192.168.1.1'
        strategy: :default
        custom_key: custom_value
      -
        customer_key: 0987654321
        customer_identifier: your_organization
        customer_identifier_param: customer_id
        valid_domains: ['your_organization.com', 'your_organization.org']
        valid_ips: ['192.168.1.1', '192.168.1.2']
        strategy: :my_auth_strategy
        custom_key: custom_value
	
hash-auth initializer:

```ruby

	clients = YAML::load( File.open('config/clients.yml') )
    add_clients clients["clients"]
	
```

**_Options in hash-auth initializer_**

Enable ip or reverse dns filtering

```ruby
	HashAuth.configure do
		domain_auth :ip
	end
	
	# or
	
	HashAuth.configure do
		domain_auth :reverse_dns
	end
```

Reverse DNS filtering caches the result. You have the option to namespace how that data gets stored. Note: client.

```ruby
	HashAuth.configure do
		cache_store_namespace "foo"
	end
	
	# will store the reverse dns lookup associated with an ip address
	# as "foo-#{ip}" in the Rails.cache
	# Example: 192.168.1.1 whould become foo-192.168.1.1
	# Defaults to "hash-auth"
```

Any custom client field can be initialized with a default value through method missing (set_default_*)

	HashAuth.configure do
		set_default_authentication_success_status_message {:status => "success" }
	end
	
will allow that value to be used in blocks later without initializing them in every client object. Ie. you could have 5 clients, three of which have a custom failure_json value in their definition and two of which will then use the default.

	## In a custom strategy…
	
	def self.on_failure(client, controller)
		@failed_authentication_status = {:status => 'failure'}
	end
	
	## In the controller…
	def my_action
		if (@authenticated)
			... Do necessary stuff
			response = @client.authentication_success_status_message
		else
			response = @failed_authentication_json
		end
	
		respond_to do |format|
			format.json { render :json => response }
		end
	end

Additionally, the default strategy for every client can be set (if not set, will revert to HashAuth::Strategies::Default)

	set_default_strategy :strategy_identifier

	
#### Implementation: _Receiving hashed requests_

In whatever controller(s) require hash authentication of requests

	validates_auth_for :action_one, :action_two

The following variables are available in implementing controller actions

	@client : HashAuth::Client - instance of client (if found, whether or not authenticated)
	@authenticated : Boolean - whether or not the hashed request was considered validated


#### Implementation: _Making hashed requests_	
In whatever controllers, models, or otherwise that require creating hash authenticated requests, use the HashAuth::WebRequest around [REST client](https://github.com/rest-client/rest-client).

	client = HashAuth.find_client 'my_organization'
	HashAuth::WebRequest.post client, 'localhost:3000/test/one', {:foo => :bar, :bar => :baz}

WebRequest supports:

	def self.get(client, url, parameters = {}, &block)
    def self.post(client, url, payload, headers = {}, &block)
    def self.patch(client, url, payload, headers = {}, &block)
    def self.put(client, url, payload, headers = {}, &block)
    def self.delete(client, url, parameters = {}, &block)
    def self.head(client, url, parameters = {}, &block)
    def self.options(client, url, parameters = {}, &block)

See [REST client](https://github.com/rest-client/rest-client) for futher detail.

## License

This project rocks and uses MIT-LICENSE.