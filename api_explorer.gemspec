$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api_explorer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api_explorer"
  s.version     = ApiExplorer::VERSION
  s.authors     = ["Anthony Figueroa"]
  s.email       = ["afigueroa@toptierlabs.com"]
  s.homepage    = "http://www.toptierlabs.com"
  s.summary     = "API Explorer is a tool that reads a specification and creates a console where developers can test webservices"
  s.description = "https://github.com/toptierlabs/api_explorer"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "jquery-rails"
  s.add_dependency "coderay", "~> 1.1.0"
  #s.add_development_dependency "sqlite3"
end
