require 'bundler/setup'
require 'rake'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty --tag ~@wip"
end

namespace :cucumber do
  Cucumber::Rake::Task.new(:wip) do |t|
    t.cucumber_opts = "--format pretty --tag @wip"
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "MongoDoc #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
