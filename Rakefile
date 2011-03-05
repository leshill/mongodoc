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

