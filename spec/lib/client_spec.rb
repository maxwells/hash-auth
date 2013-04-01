require File.expand_path('../../spec_helper', __FILE__)
require 'active_support/all'
require 'hash-auth'

describe HashAuth::Client do

  it "can be instantiated with a hash that adds getters and setters to the instance" do
    hash = {:a => :b, :c => :d}
    c = HashAuth::Client.new hash
    c.a.should == :b
    c.c.should == :d
  end

  it "does not add getters and setters to the entire Client class" do
    hash = {:a => :b, :c => :d}
    c = HashAuth::Client.new hash
    hash = {:b => :a, :d => :c}
    d = HashAuth::Client.new hash
    c.respond_to?(:a).should == true
    d.respond_to?(:a).should == false
  end
  
end