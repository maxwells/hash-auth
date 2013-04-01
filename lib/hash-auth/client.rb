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
      singleton = (class << self; self end)
      singleton.send :define_method, var.to_sym do
        instance_variable_get "@#{var}"
      end
      singleton.send :define_method, "#{var}=".to_sym do |val|
        instance_variable_set "@#{var}", val
      end
    end

    def method_missing(method, *args, &block)
      # Check config for default value
      default = "default_#{method}"
      if HashAuth.configuration.respond_to? default
        HashAuth.configuration.send default
      end
    end
  end
end