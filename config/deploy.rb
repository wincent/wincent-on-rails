set :application, 'test_app'
set :repository, '/pub/git/private/wincent.com.git'
set :branch, 'origin/master' # later this will be maint, but maint doesn't exist yet
set :scm, :git

depend :remote, :gem, :wikitext, '>= 1.0'
depend :remote, :gem, :haml, '>= 1.8.2'
depend :remote, :gem, :rails, '>= 2.0.2'
depend :remote, :gem, :rspec, '>= 1.1.3'
depend :remote, :command, 'git'
depend :remote, :command, 'monit'

desc <<-END
Target the staging environment

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
Target the production environment

This is the default unless otherwise specified, but to explicitly
target the production environment you could do:

  cap production deploy

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
  desc 'Set up persistent-folder links in "public"'
  task :public_links do
    # this is a subfolder of the "public" directory suitable for receiving file uploads and the like
    run <<-CMD
      cd #{release_path}/#{application} &&
      ln -nfs #{shared_path}/persistent #{release_path}/#{application}/public/persistent
    CMD
  end

  desc 'Restart the mongrel cluster via monit'
  task :restart, :roles => :app do
    # this overrides the built-in deploy:restart task
    sudo "/usr/local/bin/monit restart all -g #{cluster}"
  end

  desc 'Start the mongrel cluster via monit'
  task :start, :roles => :app do
    sudo "/usr/local/bin/monit start all -g #{cluster}"
  end

  desc 'Stop the mongrel cluster via monit'
  task :stop, :roles => :app do
    sudo "/usr/local/bin/monit stop all -g #{cluster}"
  end
end
after 'deploy:update_code', 'deploy:public_links'

task :after_symlink, :roles => :app do
  run "ln -s #{shared_path}/database.yml #{release_path}/#{application}/config/database.yml"
end

# eventually will run this whenever deploying before going live
desc 'Run all specs'
task :spec, :roles => :app do
  run "spec #{release_path}/#{application}/spec"
end
#before 'deploy:symlink', :spec
