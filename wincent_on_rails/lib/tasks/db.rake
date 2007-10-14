namespace :db do
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
  end

  namespace :reset do
    desc "performs the db:reset task in the development environment"
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

def migrate_in_environment env
  `env RAILS_ENV=#{env} rake db:migrate`
end

def reset_in_environment env
  `env RAILS_ENV=#{env} rake db:reset`
end
