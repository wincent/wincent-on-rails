begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  require 'spec'
end

begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end


if File.exist?(path = "spec/watirspec/watirspec.rake")
  load path
end

namespace :watirspec do
  desc 'Initialize and fetch the watirspec submodule'
  task :init do
    sh "git submodule init"
    sh "git submodule update"
  end
end

desc "Run the specs under spec/"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  # t.ruby_opts = %w[--headless] if RUBY_PLATFORM =~ /java/
  
  begin 
    require 'rcov'
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,fcntl,path_helper,yaml', '--no-rcovrt']
  rescue LoadError
  end
  
end
