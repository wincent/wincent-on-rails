namespace :search do
  desc 'populate the full-text index'
  task :index => :environment do
    puts "Starting indexing"
    start = Time.now
    [Article, Issue, Post, Topic].each { |model| index_model model }
    puts "Total time: #{Time.now - start} seconds"
  end

  desc 'drop the full-text index'
  task :drop => :environment do
    Needle.delete_all
  end

  desc 'drops the full-text index and then recreates it'
  task :reindex => ['search:drop', 'search:index']
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
