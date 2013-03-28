class TestController < ApplicationController
  #include HashAuth
  validates_auth_for :one, :two# do
    #render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
  #end
  def one
    #puts "test#one"
    #puts request.body.read
    #render :layout => false
    #render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
  end

  def two
    render :layout => false
  end

  def three
    puts "test#three"
  end
end
