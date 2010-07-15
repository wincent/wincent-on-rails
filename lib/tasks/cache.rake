namespace :cache do
  desc 'delete all cached pages (in /public)'
  task :clear => :environment do
    sweepers.each do |sweeper|
      puts "Invoking: #{sweeper}.expire_all"
      sweeper.expire_all
    end
  end
end

def sweepers
  Dir[Rails.root + 'app/sweepers/*.rb'].collect do |model|
    File.basename(model).sub(/\.rb\z/, '').classify.constantize
  end
end
