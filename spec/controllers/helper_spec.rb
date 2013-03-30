require_relative '../spec_helper'

describe TestRailsApp::TestController do

  it "extracts client from request" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=my_organization'
    client = controller.extract_client_from_request_helper
    client.customer_key.should == 1234567890
  end

  it "checks the request host for a clients valid domain" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=my_organization'
    client = controller.extract_client_from_request_helper
    controller.check_host_helper(client, 'localhost').should == true
    controller.check_host_helper(client, 'localhostwithstuffafterit').should == false
    controller.check_host_helper(client, 'prependinglocalhost').should == false
    controller.check_host_helper(client, 'localSTUFFhost').should == false
  end

  it "checks the request host for client's valid domain with wildcarding" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=your_organization'
    client = controller.extract_client_from_request_helper
    controller.check_host_helper(client, 'maps.google.com').should == true
    controller.check_host_helper(client, 'google.com').should == true
    controller.check_host_helper(client, 'google.coma').should == false
    controller.check_host_helper(client, 'google.co.uk').should == false
    controller.check_host_helper(client, 'hello.org').should == true
    controller.check_host_helper(client, 'org').should == false
  end

  it "raises error when request parameters do not match a client" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=not_an_organization'
    expect{controller.verify_hash_helper}.to raise_error
  end

  it "responds on_failure when authentication fails" do
    controller.params = Request.parse_params 'a=b&c=d&customer_id=test&signature=abcde'
    expect{controller.verify_hash_helper}.to raise_error(OnFailureError)
  end
end