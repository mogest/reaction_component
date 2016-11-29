$:.push File.expand_path("../lib", __FILE__)

require "reaction_component/version"

Gem::Specification.new do |s|
  s.name        = "reaction_component"
  s.version     = ReactionComponent::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.authors     = ["Roger Nesbitt", "Nick Johnstone"]
  s.email       = ["roger@seriousorange.com"]
  s.homepage    = "https://github.com/mogest/reaction_component"
  s.summary     = %q{TODO}
  s.description = %q{TODO}

  s.required_ruby_version = '>= 2.0'

  s.add_dependency "action_component"

  s.add_development_dependency "rspec", "~> 3.5"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
end
