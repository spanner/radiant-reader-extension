# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-reader-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-reader-extension"
  s.version     = RadiantReaderExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["William Ross"]
  s.email       = ["radiant@spanner.org"]
  s.homepage    = "radiant.spanner.org"
  s.summary     = %q{Reader/viewer/visitor login and management for Radiant CMS}
  s.description = %q{Centralises reader/member/user registration and management tasks for the benefit of other extensions}

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:

    config.gem 'radiant-reader-extension', :version => '~> #{RadiantReaderExtension::VERSION}'

  and please remember to enable ActionMailer in your project's config/environment.rb.
  }

  s.add_dependency 'radiant-layouts-extension', "~> 0.9.1"
  s.add_dependency 'radiant-mailer_layouts-extension', "~> 0.1.1"
  s.add_dependency 'authlogic', "~> 2.1.6"
  s.add_dependency 'authlogic-connect', "~> 0.0.6"
  s.add_dependency 'sanitize', "~> 2.0.1"
end