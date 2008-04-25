namespace :search do
  desc 'populate the full-text index'
  task :index => :environment do
    puts "Starting indexing"
    start = Time.now
    indexable_models.each { |model| index_model model unless model.nil? }
    puts "Total time: #{Time.now - start} seconds"
  end

  desc 'drop the full-text index'
  task :drop => :environment do
    Needle.delete_all
  end

  desc 'drops the full-text index and then recreates it'
  task :reindex => ['search:drop', 'search:index']
end

def indexable_models
  Dir["#{RAILS_ROOT}/app/models/*.rb"].collect do |model|
    klass = File.basename(model).sub(/\.rb\z/, '').classify.constantize
    klass.private_instance_methods.include?('create_needles') ? klass : nil
  end
end

def index_model klass
  puts "Indexing #{klass} model:"
  offset = 0
  start = Time.now
  while offset < klass.count do
    print '.'
    STDOUT.flush
    rows = klass.find :all, :offset => offset, :limit => 10
    rows.each do |model|
      model.send :create_needles
    end
    offset += rows.length
  end
  puts "\nIndexed #{offset} records (#{Time.now - start} seconds)"
end
