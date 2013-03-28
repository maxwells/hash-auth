module HashAuth
  class MissingConfiguration < StandardError
    def initialize
      super("Configuration for doorkeeper missing. Do you have a hash-auth initializer?")
    end
  end

  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config || (raise MissingConfiguration.new)
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

      def acquire_string_to_hash(&block)
        puts "acquire_string_to_hash set!"
        @config.instance_variable_set("@acquire_string_to_hash", block)
      end

      def hash_string(&block)
        @config.instance_variable_set("@hash_string", block)
      end

      def set_default_external_id_field(val)
        @config.instance_variable_set("@default_external_id_field", val)
      end

      def set_default_signature_param(val)
        @config.instance_variable_set("@default_signature_param", val)
      end

      def set_client_class(val)
        HashAuth::Client = val
      end
    end

    def acquire_string_to_hash
      @acquire_string_to_hash
    end

  end
end