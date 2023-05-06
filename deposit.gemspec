# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'deposit/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'killbill-deposit'
  s.version     = Deposit::VERSION
  s.authors     = 'Kill Bill core team'
  s.email       = 'killbilling-users@googlegroups.com'
  s.homepage    = 'https://killbill.io'
  s.summary     = 'Kill Bill Deposit UI mountable engine'
  s.description = 'Rails UI plugin for the Deposit plugin.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*'] + %w[MIT-LICENSE Rakefile README.md]

  s.metadata['rubygems_mfa_required'] = 'true'

  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'jquery-datatables-rails'
  s.add_dependency 'jquery-rails', '~> 4.5.1'
  s.add_dependency 'killbill-client'
  s.add_dependency 'money-rails', '~> 1.9'
  s.add_dependency 'rails', '~> 7.0'
  s.add_dependency 'sass-rails'
end
