require 'pathname'

def javascripts blob
  Dir.chdir "#{RAILS_ROOT}/public/javascripts" do
    Dir[blob].each do |f|
      puts "Processing: #{f}"
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
        `java -jar /usr/local/bin/yuicompressor.jar -o #{f.gsub(/\.max\.js\z/, '.min.js')} #{f}`
        # run them through Closure compiler -> .min.js
        #`java -jar /usr/local/bin/closure/compiler.jar --js=#{f} --js_output_file=#{f.gsub(/\.max\.js\z/, '.min.js')}`
      end
    end

    desc 'symlink minified files for deployment environment'
    task :deploy do
      javascripts '*.min.js' do |f|
        # cp file.min.js -> file.js
        FileUtils.ln_sf f, f.gsub(/\.min\.js\z/, '.js')
      end
    end

    desc 'symlink unminified files for development environment'
    task :undeploy do
      javascripts '*.max.js' do |f|
        # cp file.max.js -> file.js
        FileUtils.ln_sf f, f.gsub(/\.max\.js\z/, '.js')
      end
    end
  end
end
