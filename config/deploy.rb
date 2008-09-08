set :application, 'wincent_on_rails'
set :repository, '/pub/git/private/wincent.com.git'
set :scm, :git
set :group_writable, :false

# sudo won't run without this ("sorry, you must have a tty to run sudo")
default_run_options[:pty] = true

depend :remote, :gem, :hpricot, '>= 0.6'
depend :remote, :gem, 'rubygems-update', '>= 1.1.1' # Rails 2.1.1 itself bumps the minimum RubyGems requirement up to 1.1.1
depend :remote, :command, 'git'
depend :remote, :command, 'monit'

desc 'Show common usage patterns.'
task :help do
  puts <<-HELP

  COMMON USAGE PATTERNS

  Initial setup (once only):

    cap staging deploy:prepare      # production: cap deploy:prepare

  Run preliminary checks before deploying:

    cap staging deploy:check        # production: cap deploy:check

  Starting a cold (stopped) application (runs migrations as well):

    cap staging deploy:cold         # production: cap deploy:cold

  Deploy latest version of application and restart (no migrations):

    cap staging deploy              # production: cap deploy

  Uploading a single file:

    FILES=config/routes.rb cap staging deploy:upload
    FILES=config/routes.rb cap deploy:upload

  Putting it all together (staging environment, then production):

    cap staging deploy:check        # check dependencies
    cap staging deploy:update       # deploy latest, no restart, no migrations
    cap staging deploy:migrate_all  # run the migrations
    cap staging spec                # run the spec suite
    cap staging deploy:web:disable  # (optional) display a maintenance page
    cap staging deploy:restart      # restart server (changes go live)
    cap staging deploy:web:enable   # (optional) remove maintenance page

    cap deploy:check
    cap deploy:update
    cap deploy:migrate_all
    cap spec
    cap deploy:web:disable          # (optional)
    cap deploy:restart
    cap deploy:web:disable          # (optional)

  HELP
end

desc '(synonym for "help").'
task :usage do
  help
end

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
  set     :branch,    'origin/master'
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
  set     :branch,    'origin/maint'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy/shared'
end

task :check_target_environment do
  if not ARGV.any? { |a| a == 'staging' or a == 'production' }
    production
  end
end
on :start, :check_target_environment, :except => [ :production, :staging, :help, :usage ]

namespace :deploy do
  namespace :web do
    desc 'Display a maintenance page to visitors, effectively disabling the website'
    task :disable, :roles => :web, :except => { :no_release => true } do
      run "cp #{current_path}/public/maintenance.html #{shared_path}/system/maintenance.html"
    end
  end

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
(which would fail because the default migrate recipe doesn't run with
enough privileges to complete a migration of the production database)
it instead does an update/migrate_all/start.
  END
  task :cold do
    update
    migrate_all
    start
  end

  task :before_cleanup, :roles => :app do
    set :use_sudo, false
  end
end

# internal use only (no description)
task :after_check, :roles => :app do
  remote_branch = fetch(:branch)
  local_branch  = remote_branch.sub('origin/', '')
  `git diff --exit-code --quiet #{local_branch} #{remote_branch}`
  if $?.exitstatus != 0
    puts "*** #{local_branch} differs from #{remote_branch}: did you remember to 'git push'? ***"
  end
end

# internal use only (no description)
task :after_update, :roles => :app do
  run "cd #{current_path} && rake gems:clean"
  run "cd #{current_path} && rake gems:build"
end

# internal use only (no description)
task :after_symlink, :roles => :app do
  run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
  run "ln -s #{shared_path}/app_config.yml #{release_path}/config/app_config.yml"
end

desc 'Run all specs.'
task :spec, :roles => :app do
  run "cd #{current_path} && RAILS_ENV=test rake spec"
end
