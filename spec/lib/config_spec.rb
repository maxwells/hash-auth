require_relative '../spec_helper'

prev_config = HashAuth.configuration

describe HashAuth::Config do

  after :all do
    HashAuth.configuration = prev_config
  end

  it "sets default_customer_identifier_param (via method missing)" do
    HashAuth.configure { set_default_customer_identifier_param 'customer_identifier' }
    HashAuth.configuration.default_customer_identifier_param.should == 'customer_identifier'
  end

  it "sets default signature param (via method missing)" do
    HashAuth.configure { set_default_signature_param 'random_signature_param' }
    HashAuth.configuration.default_signature_param.should == 'random_signature_param'
  end

  it "sets default strategy" do
    expect{HashAuth.configure { set_default_strategy :my_new_strategy }}.to raise_error
    HashAuth.configure { set_default_strategy :new }
    HashAuth.configuration.default_strategy.should == HashAuth::Strategies::New
  end

  it "adds a new client" do
    client = {
      :customer_key => 'ABCDEFG',
      :customer_identifier => 'globocorp',
      :customer_identifier_param => 'id',
      :valid_domains => ['*'],
    }
    num_clients = HashAuth.clients.length
    HashAuth.configure { add_client client }
    HashAuth.clients.length.should == num_clients + 1
  end

  it "takes a block to determine what to do when authentication fails to find a matching client"

end