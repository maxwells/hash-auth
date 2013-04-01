require File.expand_path('../../spec_helper', __FILE__)

describe TestRailsApp::TestController do

  it "extracts client from request" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=my_organization'
    client = controller.extract_client_from_request_helper
    client.customer_key.should == 1234567890
  end

  it "checks the request host for a clients valid domain" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=my_organization'
    controller.instance_variable_set '@client', controller.extract_client_from_request_helper
    controller.check_host_helper('localhost').should == true
    controller.check_host_helper('localhostwithstuffafterit').should == false
    controller.check_host_helper('prependinglocalhost').should == false
    controller.check_host_helper('localSTUFFhost').should == false
  end

  it "checks the request host for client's valid domain with wildcarding" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=your_organization'
    controller.instance_variable_set '@client', controller.extract_client_from_request_helper
    controller.check_host_helper('maps.google.com').should == true
    controller.check_host_helper('google.com').should == true
    controller.check_host_helper('google.coma').should == false
    controller.check_host_helper('google.co.uk').should == false
    controller.check_host_helper('hello.org').should == true
    controller.check_host_helper('org').should == false
  end

  it "executes on_failure block when request parameters do not match a client" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=not_an_organization'
    controller.verify_hash_helper
    controller.instance_variable_get('@failure_message').should_not == nil
  end

  it "responds on_failure when authentication fails" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=test&signature=abcde'
    expect{controller.verify_hash_helper}.to raise_error(OnFailureError)
  end
end