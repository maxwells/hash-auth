class InstallHashAuthMigration < ActiveRecord::Migration
  def up
    create_table :<%= client_table_name %> do |t|
      t.string :ext_id
      t.string :ext_id_field
      t.string :hash_param_name
      t.string :salt
    end
    create_table :client_ips do |t|
      t.string :address
      t.integer :client_id
    end
    execute <<-SQL
      ALTER TABLE client_ips
        ADD CONSTRAINT fk_client_id_client
        FOREIGN KEY (client_id)
        REFERENCES <%= client_table_name %>(id);
    SQL
  end
  def down
    execute <<-SQL
      ALTER TABLE client_ips
        DROP FOREIGN KEY fk_client_id_client;
    SQL
    drop_table :<%= client_table_name %>
    drop_table :client_ips
  end
end