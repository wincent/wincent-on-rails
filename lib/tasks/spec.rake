require 'spec/rake/verify_rcov'

namespace :spec do
  RCov::VerifyTask.new(:verify => :spec) do |t|
    t.threshold = 65.4 # only adjust upwards, never downwards
    t.index_html = 'coverage/index.html'
  end

  desc 'run all stories in the stories directory'
  task :stories do
    # BUG: rake gobbles up the stdout here so user won't get any feedback along the way, only on error
    ruby 'stories/all.rb'
  end
end
