# HashAuth

HashAuth allows your Rails application to support incoming and outgoing two-factor authentication via hashing some component of an HTTPS request. Both sides of the request (your Rails app and your client or provider) must have some unique shared secret. This secret is used to create a hash of some portion of the request, ensuring that (if neither side has been compromised) only the other party could have created the request.

Solely using a shared key leaves one hole open: the ability for a third party to send a duplicate request if they are playing man in the middle, so it is important to combine the secret key with some unique data (eg. request IP and datetime) to reduce the scope of when and from where a given request is valid. Again, this only applies to duplicate requests.

## Features
- HashAuth can be configured to support multiple clients, each with their own authentication blocks (ie. customer 1 could use MD5 hash, customer 2 could use SHA256).
- Clients can be authenticated as a proxy user upon successful hash authentication (ie. if your controller action depends on having current_user, you can assign an email address to your client and have it log in that user)
- Custom blocks can be provided to (a) acquire the string to hash, (b) hash the string, or (c) perform a custom action upon authentication from a request from each indivudual client
- Enhanced security can be enabled by requiring each client to submit a GMT version of their system time to be included in the hash, which will mean any given request is only valid within a predefined window (reduces the possibility of a man in the middle attack through duplicate requests)

## Usage

##### Installation

1) Install the HashAuth gem from RubyGems

	> gem install hash-auth

2) Add it to your Rails application's Gemfile

	> gem "hash-auth"
	
3) Install it into your Rails application

	> rails g hashauth:install	

##### Configuration

The install generator will place an initializer (hashauth.rb) into your config/initializers directory. Incoming and Outgoing configuration blocks should match up in terms of creating and verifying the same hashed value. The following blocks are configurable:

	1) Acquiring the string to hash from a request that your application has received
	2) How to hash the string acquired from block 1

Additionally, if your application will be receiving signed requests

	3) What to do when authentication fails -- This defaults to returning a 401 (Forbidden)

In the case that your application accepts and makes signed requests from/to multiple clients or providers, you must configure the key:value list of clients and secret keys. By default, YAML is used.

	Clients:
		
	
##### Implementation

## Examples



This project rocks and uses MIT-LICENSE.