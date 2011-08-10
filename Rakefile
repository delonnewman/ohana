# Jeweler
pkg = 'ohana'.freeze

begin
  require 'jeweler'
  Jeweler::Tasks.new do |spec|
    spec.name        = pkg
    spec.summary     = "A lightweight Pi-Calculus based business process management system"
    spec.description = spec.summary
    spec.email       = "drnewman@phrei.org"
    spec.homepage    = "http://phrei.org"
    spec.authors     = %w{Delon Newman}

    # Dependecies
    spec.add_development_dependency('jeweler')

		spec.add_dependency('json')
		spec.add_dependency('datamapper')
		spec.add_dependency('dm-sqlite-adapter')
  end
rescue LoadError
  puts "Jeweler not available.  Install it with: gem install jeweler"
end

desc "Push changes to git and deploy to system"
task :deploy do
	sh "git push"
	sh "sudo ggem #{pkg}"
end

desc "Run test suite"
namespace :test do
  task :units do
    sh "ruby test/suite.rb"
  end
end
