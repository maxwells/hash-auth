module HashAuth
  class MissingConfiguration < StandardError
    def initialize
      super("Configuration for hash-auth missing. Do you have a hash-auth initializer?")
    end
  end

  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config || (raise MissingConfiguration.new)
  end

  def self.configuration=(val)
    @config = val
  end

  def self.clients=(val)
    @clients = val
  end

  def self.clients
    @clients
  end

  def self.find_client(name)
    @clients.select{|c| c.customer_identifier == name}[0]
  end

  def self.strategies
    return @strategies if @strategies
    
    constants = HashAuth::Strategies.constants.select { |c| Class === HashAuth::Strategies.const_get(c) }
    @strategies = constants.select{|c| c != :Base}.map{ |c| HashAuth::Strategies.const_get(c) }
    @strategies
  end

  def self.find_strategy(name)
    strategy = self.strategies.select{|s| s.identifier == name}[0]
    raise "Strategy specified with name = #{name} does not exist" unless strategy
    strategy
  end

  class Config
    class Builder
      def initialize(&block)
        @config = Config.new
        instance_eval(&block)
      end

      def build
        @config
      end

      def set_default_strategy(val)
        strategy = HashAuth.find_strategy val
        @config.instance_variable_set("@default_strategy", strategy)
      end

      def add_client(client)
        (HashAuth.clients ||= []) << create_client_from_hash_if_valid(client)
      end

      # add_clients calls add_client on a list of client hashes
      #
      # @param [Hash] clients - an Array of client hashes
      def add_clients(clients)
        clients.each do |client| 
          add_client client
        end
      end

      def create_client_from_hash_if_valid(client)
        [:customer_key, :customer_identifier, :valid_domains].each do |required_val|
          raise "Client hash is missing #{required_val}" unless client[required_val]
        end
        client[:strategy] = HashAuth.find_strategy(client[:strategy]) if client[:strategy]
        client[:valid_domains] = [client[:valid_domains]] unless client[:valid_domains].kind_of? Array
        HashAuth::Client.new client
      end

      def method_missing(method, *args, &block)
        match = /set_(default_.*)/.match method
        if match
          default_var_name = match[1]
          @config.instance_variable_set("@#{default_var_name}", args[0])
          if @config.respond_to?("#{default_var_name}".to_sym) == false
            @config.define_singleton_method "#{default_var_name}".to_sym do instance_variable_get("@#{default_var_name}") end
          end
        end
      end
    end

    def default_customer_identifier_param
      @default_customer_identifier_param || "customer_id"
    end

    def default_signature_param
      @default_signature_param || "signature"
    end

    def default_strategy
      @default_strategy || HashAuth::Strategies::Default
    end

  end
end