task :default => :test
task :test => [:spec, :cucumber]

namespace :db do
  desc 'Auto-migrate the database (destroys data)'
  task :migrate do
    require 'application'
    DataMapper.auto_migrate!
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade do
    require 'application'
    DataMapper.auto_upgrade!
  end
end

require 'spec/rake/spectask'
desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['-cfs']
end

require 'cucumber/rake/task'
desc "Run cucumber features"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = '--format pretty'
end

require "rake/gempackagetask"
require "rake/rdoctask"

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "sinatra-doorman"
  s.version           = "0.1.0"
  s.summary           = "A user authentication middleware built with Sinatra and Warden"
  s.author            = "John Mendonca"
  s.email             = "joaosinho@gmail.com"
  s.homepage          = "http://github.com/johnmendonca/sinatra-doorman"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.rdoc)
  s.rdoc_options      = %w(--main README.rdoc)

  # Add any extra files to include in the gem
  s.files             = %w(MIT-LICENSE Rakefile README.rdoc) + Dir["views/**/*"] + Dir["lib/**/*"]
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  # s.add_dependency("some_other_gem", "~> 0.1.0")
  s.add_dependency("sinatra", "~> 1.0.a")
  s.add_dependency("warden", "~> 0.9.0")
  s.add_dependency("pony")
  s.add_dependency("dm-core", "~> 0.10.2")
  s.add_dependency("dm-validations", "~> 0.10.2")
  s.add_dependency("dm-timestamps", "~> 0.10.2")

  # If your tests use any gems, include them here
  s.add_development_dependency("rspec")
  s.add_development_dependency("cucumber")
  s.add_development_dependency("webrat")
  s.add_development_dependency("rack-test")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec

  # Generate the gemspec file for github.
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end
