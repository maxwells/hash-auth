class TestController < ApplicationController
  validates_auth_for :all

  def one
    message = {:message => @failure_message || 'ok'}
    puts message.inspect
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
end
