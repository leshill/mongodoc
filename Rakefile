require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mongo_doc_rails2"
    gem.summary = %Q{ODM for MongoDB - for Rails 2.3.x}
    gem.description = %Q{ODM for MongoDB - for Rails 2.3.x}
    gem.email = "leshill@gmail.com"
    gem.homepage = "http://github.com/leshill/mongodoc"
    gem.authors = ["Les Hill"]
    gem.add_dependency "activesupport", ">= 2.3.4"
    gem.add_dependency "mongo", ">= 1.0.1"
    gem.add_dependency "bson", ">= 1.0.1"
    gem.add_dependency "bson_ext", ">= 1.0.1"
    gem.add_dependency "durran-validatable", "= 2.0.1"
    gem.add_dependency "leshill-will_paginate", "= 2.3.11"
    gem.add_development_dependency "rspec", "= 1.3.0"
    gem.add_development_dependency "cucumber", ">= 0.6.2"
  end
  Jeweler::GemcutterTasks.new
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
  rdoc.title = "MongoDoc #{version}"
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

namespace :mongoid do
  desc 'Sync criteria from Mongoid'
  task :sync do
    require 'pathname'

    src_dir = Pathname.new('../durran-mongoid/lib/mongoid')
    dest_dir = Pathname.new('lib/mongoid')
    dest_dir.mkpath
    %w(criteria.rb contexts/paging.rb contexts/enumerable.rb criterion extensions/symbol/inflections.rb extensions/hash/criteria_helpers.rb matchers).each do |f|
      src = src_dir + f
      if src.directory?
        FileUtils.cp_r(src, dest_dir)
      else
        dest = dest_dir + f
        dest.dirname.mkpath
        FileUtils.cp(src, dest)
      end
    end
  end
end

namespace :bench do
  desc 'Run benchmark for MongoDoc'
  task 'mongo_doc' do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'perf/mongo_document'
    benchmark("MongoDoc saving documents", MongoDocument.new)
  end

  desc 'Run benchmark for MongoDoc Object'
  task 'mongo_object' do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'perf/mongo_doc_object'
    benchmark("MongoDoc saving objects", MongoDocObject.new)
  end

  desc 'Run profiler for driver'
  task 'driver' do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'perf/ruby_driver'
    benchmark("Ruby driver saving hashes", RubyDriver.new)
  end
end

namespace :prof do
  desc 'Run profiler for MongoDoc'
  task 'mongo_doc' do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'perf/mongo_document'
    profile("MongoDoc saving documents", MongoDocument.new)
  end

  desc 'Run profiler for MongoDoc Object'
  task 'mongo_object' do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'perf/mongo_doc_object'
    profile("MongoDoc saving objects", MongoDocObject.new)
  end

  desc 'Run profiler for driver'
  task 'driver' do
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
    require 'perf/ruby_driver'
    profile("Ruby driver saving hashes", RubyDriver.new)
  end

  def benchmark(what, runner)
    puts "Benchmark: " + what

    runner.generate(10000)

    Benchmark.bm do |bm|
      bm.report(what + " writes") do
        runner.writes(10000)
      end
    end

    Benchmark.bm do |bm|
      bm.report(what + " reads") do
        runner.reads(10000)
      end
    end

    Benchmark.bm do |bm|
      bm.report(what + " query") do
        runner.query_all
      end
    end
  end

  def profile(what, runner)
    puts "Profiling: " + what
    RubyProf.start

    runner.generate(1000)
    runner.writes(1000)
    runner.reads(1000)
    runner.query_all

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, 0)
  end
end

