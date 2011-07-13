# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-reader-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-reader-extension"
  s.version     = RadiantReaderExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantReaderExtension::AUTHORS
  s.email       = RadiantReaderExtension::EMAIL
  s.homepage    = RadiantReaderExtension::URL
  s.summary     = RadiantReaderExtension::SUMMARY
  s.description = RadiantReaderExtension::DESCRIPTION

  s.add_dependency 'radiant-layouts-extension', "~> 1.1.3"
  s.add_dependency 'radiant-mailer_layouts-extension', "~> 0.1.1"
  s.add_dependency 'authlogic', "~> 2.1.6"
  s.add_dependency 'sanitize', "~> 2.0.1"
  s.add_dependency 'snail', "~> 0.5.5"
  s.add_dependency 'vcard', "~> 0.1.1"
  s.add_dependency 'fastercsv', "~> 1.5.4"

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

end