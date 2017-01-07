# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib/', __FILE__)

require 'reactive-ruby/version'

Gem::Specification.new do |s|
  s.name         = 'hyper-react'
  s.version      = React::VERSION

  s.authors       = ['David Chang', 'Adam Jahn', 'Mitch VanDuyn']
  s.email        = 'reactrb@catprint.com'
  s.homepage     = 'http://ruby-hyperloop.io/gems/reactrb/'
  s.summary      = 'Opal Ruby wrapper of React.js library.'
  s.license      = 'MIT'
  s.description  = "Write React UI components in pure Ruby."
  s.files          = `git ls-files`.split("\n")
  s.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']

  s.add_dependency 'opal', '>= 0.8.0'
  s.add_dependency 'opal-activesupport', '>= 0.2.0'
  s.add_dependency 'react-rails'
  s.add_development_dependency 'rake', '< 11.0'
  s.add_development_dependency 'rspec-rails', '3.3.3'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'opal-rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'opal-jquery'

  # For Test Rails App
  s.add_development_dependency 'rails', '4.2.4'
  s.add_development_dependency 'mime-types', '< 3'
  s.add_development_dependency 'opal-rails'
  s.add_development_dependency 'nokogiri', '< 1.7'
  if RUBY_PLATFORM == 'java'
    s.add_development_dependency 'jdbc-sqlite3'
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
    s.add_development_dependency 'therubyrhino'
  else
    s.add_development_dependency 'sqlite3', '1.3.10'
    s.add_development_dependency 'therubyracer', '0.12.2'
  end
end
