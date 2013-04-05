$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hash-auth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hash-auth"
  s.version     = HashAuth::VERSION
  s.authors     = ["Max Lahey"]
  s.email       = ["maxwellslahey@gmail.com"]
  s.homepage    = "http://maxwells.github.com"
  s.summary     = "Rails gem to authenticate HTTP requests by hashing request components and passing as parameter"
  s.description = "HashAuth allows your Rails application to support incoming and outgoing two-factor authentication via hashing some component of an HTTPS request. Both sides of the request (your Rails app and your client or provider) must have some unique shared secret. This secret is used to create a hash of some portion of the request, ensuring that (if neither side has been compromised) only the other party could have created the request."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "rest-client", "~> 1.6.7"

end
