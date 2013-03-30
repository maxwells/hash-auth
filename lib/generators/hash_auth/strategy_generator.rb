class HashAuth::StrategyGenerator < ::Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  desc "Generates a HashAuth strategy."

  def strategy
    template "strategy.rb", "lib/hash-auth/#{file_name}.rb"
  end

end
