$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "jav/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "jav"
  spec.version = Jav::VERSION
  spec.authors = ["Adrian Marin", "Mihai Marin", "Paul Bob"]
  spec.email = ["jav@javhq.io"]
  spec.homepage = "https://javhq.io"
  spec.summary = "Admin panel framework and Content Management System for Ruby on Rails."
  spec.description = "Jav is a very custom Content Management System for Ruby on Rails that saves engineers and teams months of development time by building user interfaces and logic using configuration rather than traditional coding; When configuration is not enough, you can fallback to familiar Ruby on Rails code."
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["bug_tracker_uri"] = "https://github.com/jav-hq/jav/issues"
    spec.metadata["changelog_uri"] = "https://javhq.io/releases"
    spec.metadata["documentation_uri"] = "https://docs.javhq.io"
    spec.metadata["homepage_uri"] = "https://javhq.io"
    spec.metadata["source_code_uri"] = "https://github.com/jav-hq/jav"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.required_ruby_version = ">= 2.6.0"
  spec.post_install_message = "Thank you for using Jav "

  spec.files = Dir["{bin,app,config,db,lib,public}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "jav.gemspec", "Gemfile", "Gemfile.lock"]

  spec.add_dependency "activerecord", ">= 8.0"
  spec.add_dependency "actionview", ">= 8.0"
  spec.add_dependency "pagy"
  spec.add_dependency "zeitwerk", ">= 2.6.2"
  spec.add_dependency "httparty"
  spec.add_dependency "active_link_to"
  spec.add_dependency "view_component", ">= 2.54.0"
  spec.add_dependency "turbo-rails", "> 2.0"
  spec.add_dependency "turbo_power", "~> 0.6.0"
  spec.add_dependency "addressable"
  spec.add_dependency "meta-tags"
  spec.add_dependency "dry-initializer"
  spec.add_dependency "docile"
  spec.add_dependency "inline_svg"
end
