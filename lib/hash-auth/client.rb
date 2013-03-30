module HashAuth
  class Client
    # The hash passed in to a new client will initialize this Client object
    # with getters and setters for each key in the hash. The default value
    # for each getter will be the associated value passed in the hash
    def initialize(hash)
      hash.each do |key,value|
        add_instance_getters_and_setters key
        send "#{key}=", value
      end
    end

    # Add instance specific getters and setters for the name passed in,
    # so as to allow different Client objects to have different properties
    # that are accessible by . notation
    def add_instance_getters_and_setters(var)
      define_singleton_method var.to_sym do
        instance_variable_get "@#{var}"
      end
      define_singleton_method "#{var}=".to_sym do |val|
        instance_variable_set "@#{var}", val
      end
    end

    def customer_identifier_param
      HashAuth.configuration.default_customer_identifier_param
    end

    def strategy
      HashAuth.configuration.default_strategy
    end
  end
end