require 'pathname'

def javascripts blob
  Dir.chdir "#{RAILS_ROOT}/public/javascripts" do
    Dir[blob].each do |f|
      puts "Processsing: #{f}"
      yield f
    end
  end
end

namespace :js do
  namespace :minify do
    desc 'create minified files'
    task :create do
      javascripts '*.max.js' do |f|
        # run them through yuicompressor -> .min.js
        `java -jar /usr/bin/yuicompressor -v -o #{f.gsub(/\.max\.js\z/, '.min.js')} #{f}`
      end
    end

    desc 'move minified files into place for deployment environment'
    task :deploy do
      javascripts '*.min.js' do |f|
        # cp file.min.js -> file.js
        FileUtils.cp f, f.gsub(/\.min\.js\z/, '.js')
      end
    end

    desc 'move unminified files into place for development environment'
    task :undeploy do
      javascripts '*.max.js' do |f|
        # cp file.max.js -> file.js
        FileUtils.cp f, f.gsub(/\.max\.js\z/, '.js')
      end
    end
  end
end