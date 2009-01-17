namespace :db do
  namespace :sessions do
    desc 'Thin the sessions table (clears only old records)'
    task :thin => :environment do
      query = "DELETE FROM #{session_table_name} WHERE updated_at < DATE_SUB(NOW(), INTERVAL 24 HOUR)"
      ActiveRecord::Base.connection.execute query
    end

    desc 'Clear the sessions table quickly (using TRUNCATE)'
    task :truncate => :environment do
      ActiveRecord::Base.connection.execute "TRUNCATE #{session_table_name}"
    end
  end

  namespace :migrate do
    desc "performs the db:migrate task in the development environment"
    task :development do
      migrate_in_environment 'development'
    end

    desc "performs the db:migrate task in the test environment"
    task :test do
      migrate_in_environment 'test'
    end

    desc "performs the db:migrate task in the production environment"
    task :production do
      migrate_in_environment 'production'
    end

    desc "performs the db:migrate task in all environments"
    task :all => [:development, :test, :production]

    namespace :reset do
      desc "performs the db:migrate:reset task in the development environment"
      task :development do
        reset_in_environment 'development'
      end

      desc "performs the db:reset task in the test environment"
      task :test do
        reset_in_environment 'test'
      end

      desc "performs the db:reset task in the production environment"
      task :production do
        reset_in_environment 'production'
      end

      desc 'drops, creates then migrates the database in all environments'
      task :all => [:development, :test, :production]
    end
  end
end

def migrate_in_environment env
  # could use Rake::Task['db:migrate'].invoke here, but that won't work when we try to modify all environments at once
  # (it will only run for the first environment and then will think that it's already run for the others)
  puts `env RAILS_ENV=#{env} rake db:migrate`
end

def reset_in_environment env
  puts `env RAILS_ENV=#{env} rake db:migrate:reset`
end
