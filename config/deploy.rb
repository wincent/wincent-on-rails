set :application, 'wincent_on_rails'
set :repository, '/pub/git/private/wincent.com.git'
#set :local_repository, 'git.wincent.com:/pub/git/private/wincent.com.git' # for Cap > 2.2.0
set :scm, :git
set :git_enable_submodules, true
set :group_writable, :false
set :lockdown_user, 'ghurrell'

# sudo won't run without this ("sorry, you must have a tty to run sudo")
default_run_options[:pty] = true

depend :remote, :gem, :hpricot, '>= 0.6'
depend :remote, :gem, 'rubygems-update', '>= 1.3.1' # Rails 2.2 bumps the minimum RubyGems requirement up
depend :remote, :gem, 'rack', '>= 0.9.1'            # Rails 2.3 requires rack 0.9.0 minimum
depend :remote, :gem, 'mkdtemp', '>= 1.0'           # needed for "rake spec", don't want to freeze
depend :remote, :command, 'git'
depend :remote, :command, 'monit'

desc 'Show common usage patterns.'
task :help do
  puts <<-HELP

  COMMON USAGE PATTERNS

  Uploading a single file:

    FILES=config/routes.rb cap staging deploy:upload
    FILES=config/routes.rb cap deploy:upload

  Performing a complete deployment cycle (staging environment then production):

    cap _2.2.0_ staging deploy:unlock       # relax permissions (necessary to deploy)
    cap _2.2.0_ staging deploy:check        # check dependencies
    cap _2.2.0_ staging deploy:update       # deploy latest, no restart, no migrations
    cap _2.2.0_ staging deploy:migrate_test # run the migrations on the test database
    cap _2.2.0_ staging spec                # run the spec suite
    cap _2.2.0_ staging deploy:web:disable  # (optional) display a maintenance page
    cap _2.2.0_ staging deploy:migrate_all  # run all other migrations
    cap _2.2.0_ staging deploy:restart      # restart server (changes go live)
    cap _2.2.0_ staging deploy:web:enable   # (optional) remove maintenance page
    cap _2.2.0_ staging deploy:lockdown     # tighten permissions again

    cap _2.2.0_ deploy:unlock
    cap _2.2.0_ deploy:check
    cap _2.2.0_ deploy:update
    cap _2.2.0_ deploy:migrate_test
    cap _2.2.0_ spec
    cap _2.2.0_ deploy:web:disable          # (optional)
    cap _2.2.0_ deploy:migrate_all
    cap _2.2.0_ deploy:restart
    cap _2.2.0_ deploy:web:enable           # (optional)
    cap _2.2.0_ deploy:lockdown

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
  depend  :remote,    :directory, '/home/kreacher.wincent.com/deploy/shared/files'
  depend  :remote,    :directory, '/home/kreacher.wincent.com/deploy/shared/system'
  depend  :remote,    :directory, '/home/kreacher.wincent.com/deploy/shared/system/products'
  depend  :remote,    :directory, '/home/kreacher.wincent.com/deploy/shared/system/products/icons'
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
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy/shared/files'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy/shared/system'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy/shared/system/products'
  depend  :remote,    :directory, '/home/rails.wincent.com/deploy/shared/system/products/icons'
end

task :check_target_environment do
  if not ARGV.any? { |a| a == 'staging' or a == 'production' }
    production
  end
end
on :start, :check_target_environment, :except => [ :production, :staging, :help, :usage ]

def change_shell shell
  app_user = user
  set :user, lockdown_user

  # Capistrano bug: "-p" commandline switch doesn't actually set password
  set :password, Capistrano::CLI.password_prompt if password.nil?
  sudo "chsh -s #{shell} #{app_user}"
end

namespace :deploy do
  desc 'Relax permissions (necessary for deployment)'
  task :unlock, :roles => :app do
    change_shell '/bin/sh'
  end

  desc 'Tighten permissions (locks down the application after deployment)'
  task :lockdown, :roles => :app do
    change_shell '/sbin/nologin'
  end

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

  desc 'Migrate the test database'
  task :migrate_test do
    set :rails_env, 'test'
    migrate
  end

  desc 'Migrate the development database'
  task :migrate_development do
    set :rails_env, 'development'
    migrate
  end

  desc 'Migrate the production database'
  task :migrate_production do
    # the "migrations" environment is same as "production",
    # but with additional privileges necessary for migrations
    set :rails_env, 'migrations'
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

  current_branch = `git symbolic-ref HEAD 2>/dev/null`.chomp.sub('refs/heads/', '')
  if current_branch != local_branch
    puts "*** currently on branch #{current_branch} (expected #{local_branch}): sure you're working on the right branch? ***"
  end
end

# internal use only (no description)
task :after_update, :roles => :app do
  run "cd #{current_path} && rake gems:clean"
  run "cd #{current_path} && rake gems:build"
  run "cd #{current_path} && rake js:minify:deploy"
end

# internal use only (no description)
task :after_symlink, :roles => :app do
  run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
  run "ln -s #{shared_path}/app_config.yml #{release_path}/config/app_config.yml"
  run "rm -rf #{release_path}/files"
  run "ln -s #{shared_path}/files #{release_path}/files"
end

desc 'Run all specs.'
task :spec, :roles => :app do
  run "cd #{current_path} && RAILS_ENV=test rake spec"
end
