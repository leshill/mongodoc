lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "mongo_doc/version"

Gem::Specification.new do |s|
  s.required_rubygems_version = '>= 1.3.6'

  s.name = 'mongo_doc'
  s.version = MongoDoc::VERSION
  s.authors = ['Les Hill']
  s.description = 'ODM for MongoDB'
  s.summary = 'ODM for MongoDB'
  s.homepage = 'http://github.com/leshill/mongodoc'
  s.email = 'leshill@gmail.com'

  s.require_path = "lib"

  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.textile Rakefile)

  s.add_runtime_dependency('activemodel', ['>= 3.0.0'])
  s.add_runtime_dependency('activesupport', ['>= 3.0.0'])
  s.add_runtime_dependency('bson_ext', ['>= 1.3.1'])
  s.add_runtime_dependency('mongo', ['>= 1.3.1'])
  s.add_runtime_dependency('tzinfo', ['>= 0.3.22'])
  s.add_development_dependency('cucumber', ['>= 0.10.0'])
  s.add_development_dependency('rspec', ['>= 2.5.0'])
end
