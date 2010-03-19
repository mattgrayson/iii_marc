require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "iii_marc"
    gem.summary = %Q{Utilities for interacting with III Millennium WebPac. 
      Primary goal is to retrieve and parse bibliographic records via the 
      WebPac proto-MARC output.}
    gem.description = gem.summary
    gem.email = "mattgrayson@eitheror.org"
    gem.homepage = "http://github.com/mattgrayson/iii_marc"
    gem.authors = ["Matt Grayson"]
    gem.add_development_dependency "shoulda"
    gem.add_development_dependency "fakeweb"
    gem.add_runtime_dependency "enhanced_marc"
    gem.add_runtime_dependency "htmlentities"
    gem.add_runtime_dependency "httparty"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "iii_marc #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
