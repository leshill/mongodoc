require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mongodoc"
    gem.summary = %Q{ODM for MongoDB}
    gem.description = %Q{ODM for MongoDB}
    gem.email = "leshill@gmail.com"
    gem.homepage = "http://github.com/leshill/mongodoc"
    gem.authors = ["Les Hill"]
    gem.add_dependency "mongo", "= 0.16"
    gem.add_dependency "durran-validatable", "= 1.8.2"
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "cucumber"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty --tag ~@wip"
end

namespace :cucumber do
  Cucumber::Rake::Task.new(:wip) do |t|
    t.cucumber_opts = "--format pretty --tag @wip"
  end
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mongodoc #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :mongo do
  desc 'Start mongod'
  task :start do
    default_config = { "dbpath" => "/data/db" }
    config = begin
      YAML.load_file(File.join(File.dirname(__FILE__), 'mongod.yml'))
    rescue Exception => e
      {}
    end
    config = default_config.merge(config)
    sh("nohup #{config['mongod'] || 'mongod'} --dbpath #{config['dbpath']} &")
    puts "\n"
  end
end
