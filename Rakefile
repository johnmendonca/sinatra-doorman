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
