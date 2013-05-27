Dir["test/dummy/lib/hash-auth/*.rb"].each {|file| require "hash-auth/#{File.basename file, '.rb'}" }

HashAuth.configure do
  
  cur_dir = File.expand_path(File.dirname(__FILE__))
  clients = YAML::load( File.open(File.join(cur_dir, '../clients.yml') ) )
  add_clients clients["clients"]
  domain_auth :ip

end