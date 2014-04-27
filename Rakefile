require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "leanback"
  gem.homepage = "http://github.com/obi-a/leanback"
  gem.license = "MIT"
  gem.summary = %Q{lightweight Ruby interface to CouchDB}
  gem.description = %Q{lightweight Ruby interface to CouchDB}
  gem.email = "obioraakubue@yahoo.com"
  gem.authors = ["Obi Akubue"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :repl do
  leanback_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'leanback/lib/leanback'))
  irb = "bundle exec pry -r #{leanback_file}"
  sh irb
end

task :r => :repl

task :default => :test
