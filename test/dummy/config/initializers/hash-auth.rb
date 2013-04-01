HashAuth.configure do
  
  clients = YAML::load( File.open('config/clients.yml') )
  add_clients clients["clients"]

end