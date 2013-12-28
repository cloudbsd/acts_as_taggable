$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_taggable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_taggable"
  s.version     = ActsAsTaggable::VERSION
  s.authors     = ["Qi Li"]
  s.email       = ["cloudbsd@gmail.com"]
  s.homepage    = "http://github.com/cloudbsd/acts_as_taggable"
  s.summary     = "Tag plugin for Rails 4+."
  s.description = "A tagging plugin for Rails applications that allows for custom tagging along dynamic contexts."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.2"

  s.add_development_dependency "sqlite3"
end
