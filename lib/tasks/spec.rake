require 'spec/rake/verify_rcov'

namespace :spec do
  RCov::VerifyTask.new(:verify => :spec) do |t|
    t.threshold = 65.4 # only adjust upwards, never downwards
    t.index_html = 'coverage/index.html'
  end
end
