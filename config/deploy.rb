# Initial setup (once only):
#
#   cap staging deploy:prepare
#   cap deploy:prepare
#
# Run preliminary checks before deploying:
#
#   cap staging deploy:check
#   cap deploy:check
#
# Starting a cold (stopped) application (runs migrations as well):
#
#   cap staging deploy:cold
#   cap deploy:cold
#
# Deploy latest version of application and restart (no migrations):
#
#   cap staging deploy
#   cap deploy
#
# Putting it all together:
#   - deploy latest version of application (no restart, no migrations)
#   - perform migrations
#   - run spec suite
#   - restart application server
#
#   cap staging deploy:update
#   cap staging deploy:migrate_all
#   cap staging spec
#   cap staging deploy:restart
#   cap deploy:update
#   cap deploy:migrate_all
#   cap spec
#   cap deploy:restart

set :application, 'wincent_on_rails'
set :repository, '/pub/git/private/wincent.com.git'
set :branch, 'origin/maint'
set :scm, :git
set :group_writable, :false

# sudo won't run without this ("sorry, you must have a tty to run sudo")
default_run_options[:pty] = true

depend :remote, :gem, :wikitext, '>= 1.0'
depend :remote, :gem, :haml, '>= 1.8.2'
depend :remote, :gem, :rails, '>= 2.0.2'
depend :remote, :gem, :rspec, '>= 1.1.3'
depend :remote, :command, 'git'
depend :remote, :command, 'monit'

desc <<-END
Target the staging environment.

For example, to deploy to the staging environment you could do:

  cap staging deploy

END
task :staging do
  set     :user,      'kreacher.wincent.com'
  role    :app,       'kreacher.wincent.com'
  role    :web,       'kreacher.wincent.com'
  role    :db,        'kreacher.wincent.com', :primary => true
  set     :deploy_to, '/home/kreacher.wincent.com/deploy'
  set     :cluster,   'staging'
  depend  :remote,    :directory, '/home/kreacher.wincent.com/deploy'
  depend  :remote,    :directory, '/home/kreacher.wincent.com/deploy/shared'
end

desc <<-END
Target the production environment.

This is the default unless otherwise specified so the following
are equivalent:

  cap production deploy
  cap deploy

END
task :production do
  set     :user,      'rails.wincent.com'
  role    :app,       'rails.wincent.com'
  role    :web,       'rails.wincent.com'
  role    :db,        'rails.wincent.com', :primary => true
  set     :deploy_to, '/home/rails.wincent.com/deploy'
  set     :cluster,   'production'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy/shared'
end

task :check_target_environment do
  if not ARGV.any? { |a| a == 'staging' or a == 'production' }
    production
  end
end
on :start, :check_target_environment, :except => [ :production, :staging ]

namespace :deploy do
  desc 'Restart the mongrel cluster via monit.'
  task :restart, :roles => :app do
    sudo "/usr/local/bin/monit -g #{cluster} restart all"
  end

  desc 'Start the mongrel cluster via monit.'
  task :start, :roles => :app do
    sudo "/usr/local/bin/monit -g #{cluster} start all"
  end

  desc 'Stop the mongrel cluster via monit.'
  task :stop, :roles => :app do
    sudo "/usr/local/bin/monit -g #{cluster} stop all"
  end

  desc 'Migrate test, production and development databases'
  task :migrate_all do
    set :rails_env, 'test'
    migrate
    set :rails_env, 'development'
    migrate
    set :rails_env, 'migrations' # this is production, but with additional privileges necessary for migrations
    migrate
  end

  desc <<-END
Deploys and starts a "cold" (not running) application.

This is an override of the default "deploy:cold" recipe that comes with
Capistrano. Rather than performing an update/migrate/start sequence
(which would fail because the default migrate precipe doesn't run with
enough privileges to complete a migration of the production database)
it instead does an update/migrate_all/start.
  END
  task :cold do
    update
    migrate_all
    start
  end
end

task :after_symlink, :roles => :app do
  run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
end

# eventually will run this whenever deploying before going live
desc 'Run all specs.'
task :spec, :roles => :app do
  run "spec #{release_path}/spec"
end
#before 'deploy:symlink', :spec
