class TestController < ApplicationController
  validates_auth_for :one, :two

  def one
    #puts "test#one"
    #puts request.body.read
    #render :layout => false
    #render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
    puts "host: #{request.host}"
    puts "domain: #{request.domain}"
    puts "format: #{request.format}"
    puts "query_string: #{request.query_string}"
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
