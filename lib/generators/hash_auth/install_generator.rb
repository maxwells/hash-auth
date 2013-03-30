class HashAuth::InstallGenerator < ::Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)
  desc "Installs HashAuth."

  def install
    template "initializer.rb", "config/initializers/hash-auth.rb"
  end

end
