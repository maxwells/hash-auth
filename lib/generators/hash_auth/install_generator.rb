class HashAuth::InstallGenerator < ::Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)
  desc "Installs HashAuth."

  argument :client_class_name, :type => :string, :default => "Client"
  argument :client_table_name, :type => :string, :default => "Client".tableize

  def install
    template "initializer.rb", "config/initializers/hash-auth.rb"
    template "client.rb", "app/models/#{clients_class_name}"
    migration_template 'migration.rb', 'db/migrate/install_hash_auth.rb'
  end

  private
  def clients_class_name
    client_class_name.singularize.constantize
  end

  def clients_class_file_name
    client_class_name.tableize.singularize
  end

  def override_table_name?
    (clients_table_name_tableized != client_class_name.tableize ? "set_table_name '#{client_class_name.tableize}'" : "")
  end

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end
end
