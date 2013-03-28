module HashAuth
  class ClientIp < ActiveRecord::Base
    attr_accessor :client_id, :address, :client
    belongs_to :client, :class_name => "HashAuth::Client", :foreign_key => "client_id"
  end
end