class <%= clients_class_name %> < ActiveRecord::Base
  <%= override_table_name? %>
  attr_accessible :ext_id, :ext_id_field, :hash_param_name, :salt, :acceptable_ips
  has_many :acceptable_ips, :foreign_key => 'client_id', :class_name => "HashAuth::ClientIp"
end