HashAuth.configure do

  ## Block to allow dynamic loading of customer keys (Optional)
  #### Could be from YAML
  #### Could be from DB
  
  # add_clients do |clients|
  #   YAML::load( File.open('../clients.yml') )
  # end


  ## Any attributes can be added to a client object at initialization.
  #### The default can be added to HashAuth configuration and will be picked up in every strategy automagically
  #### Default values must be set with set_default_* methods and will be picked up by [client].* methods
  # eg.
  # set_default_foo_bar 'bar baz'
  #
  # client.foo_bar will return 'bar baz' unless specifically set for that client


  ## Set default strategy by handle
  # set_default_strategy :strategy_fifty_one



end