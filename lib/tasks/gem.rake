require 'fileutils'
require 'pathname'

namespace :gems do
  desc 'clean up intermediate build products in unpacked gems'
  task :clean do
    Dir["#{RAILS_ROOT}/vendor/gems/**/ext"].each do |extension|
      Pathname.new(extension).find do |path|
        case path when /.+\/Makefile\z/, /\/.+\.log\z/, /\/.+\.o\z/
          FileUtils.rm path
        end
      end
    end
  end
end
