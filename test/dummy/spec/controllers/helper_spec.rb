require File.expand_path('../../spec_helper', __FILE__)

describe TestController do

  it "extracts client from request" do
    controller.params = RequestHelper.parse_params 'a=b&c=d&customer_id=my_organization'
    client = controller.extract_client_from_request_helper
    client.customer_key.should == 1234567890
  end

  it "checks the request host for a clients valid domain" do
    controller.params = RequestHelper.parse_params 'a=b&c=d&customer_id=my_organization'
    controller.instance_variable_set '@client', controller.extract_client_from_request_helper
    controller.check_host_helper('localhost').should == true
    controller.check_host_helper('localhostwithstuffafterit').should == false
    controller.check_host_helper('prependinglocalhost').should == false
    controller.check_host_helper('localSTUFFhost').should == false
  end

  it "checks the request host for client's valid domain with wildcarding" do
    controller.params = RequestHelper.parse_params 'a=b&c=d&customer_id=your_organization'
    controller.instance_variable_set '@client', controller.extract_client_from_request_helper
    controller.check_host_helper('maps.google.com').should == true
    controller.check_host_helper('google.com').should == true
    controller.check_host_helper('google.coma').should == false
    controller.check_host_helper('google.co.uk').should == false
    controller.check_host_helper('hello.org').should == true
    controller.check_host_helper('org').should == false
  end

  describe "verify hash method" do

    describe "with IP authentication" do

      before :each do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("192.168.0.1")
        HashAuth.configuration.instance_variable_set '@domain_auth', :ip
      end

      it "returns proper failure message when no matching client is found" do
        get :one, {:a => "b", :customer_id => "not a real organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Not a valid client'
      end

      it "returns proper failure message when signature is invalid" do
        get :one, {:a => "b", :customer_id => "my_organization", :signature => 'not a real signature'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Signature hash is invalid'
      end

      it "returns proper failure message when request ip is invalid" do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("192.168.1.1")
        get :one, {:a => "b", :customer_id => "my_organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Request coming from invalid IP'
      end

      it "validates request based on remote_ip" do
        get :one, {:a => "b", :customer_id => "my_organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == "ok"
      end

    end

    describe "with reverse DNS authentication" do

      before :each do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("17.178.96.59")
        HashAuth.configuration.instance_variable_set '@domain_auth', :reverse_dns
      end

      it "returns proper failure message when no matching client is found" do
        get :one, {:a => "b", :customer_id => "not a real organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Not a valid client'
      end

      it "returns proper failure message when signature is invalid" do
        get :one, {:a => "b", :customer_id => "my_organization", :signature => 'not a real signature'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Signature hash is invalid'
      end

      it "returns proper failure message when reverse dns host is invalid" do
        ActionDispatch::Request.any_instance.stub(:remote_ip).and_return("173.194.43.37")
        get :one, {:a => "b", :customer_id => "my_organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Request coming from invalid domain'
      end

      it "validates request based on remote_ip" do
        get :one, {:a => "b", :customer_id => "my_organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == "ok"
      end

    end

    describe "with no ip based authentication" do

      before :all do
        HashAuth.configuration.instance_variable_set '@domain_auth', :none
      end

      it "returns proper failure message when no matching client is found" do
        get :one, {:a => "b", :customer_id => "not a real organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Not a valid client'
      end

      it "returns proper failure message when signature is invalid" do
        get :one, {:a => "b", :customer_id => "my_organization", :signature => 'not a real signature'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == controller.instance_variable_get('@failure_message')
        response_hash['message'].should == 'Signature hash is invalid'
      end

      it "validates request based on remote_ip when HashAuth.config.domain_auth == :ip" do
        get :one, {:a => "b", :customer_id => "my_organization", :signature => '8b1207c76c1c2b982885a1338feaf3c8a115afa280836703490e42e6b1944516'}
        response_hash = JSON.parse response.body
        response_hash['message'].should == "ok"
      end

    end

  end
end