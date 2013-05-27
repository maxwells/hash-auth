class TestController < ApplicationController
  validates_auth_for :all

  def one
    message = {:message => @failure_message || 'ok'}
    respond_to do |format|
      format.html { render :json => message }
      format.json { render :json => message }
    end
  end

  def two
    respond_to do |format|
      format.html { render :json => {:message => "ok"} }
      format.json { render :json => {:message => "ok"} }
    end
  end

  def three
    puts "test#three"
  end

  def extract_client_from_request_helper
    extract_client_from_request
  end

  def check_host_helper(host)
    check_host(host)
  end

  def verify_hash_helper
    verify_hash
  end
end
