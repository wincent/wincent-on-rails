# without this we don't get password prompts from Git
default_run_options[:pty] = true



# note that the application is in a subdir of the repository
# so we need to set up NGinx to look for public files at:
#   #{current_path}/wincent_on_rails/public
# and Mongrel needs to know that the app root is actually:
#   #{current_path}/wincent_on_rails
set :repository,        'user@host:/pub/git/private/wincent.com'
set :branch,            'origin/maint'

set :scm,               :git

# the SSH user
set :user,              'wincent.com'

depend :remote, :gem, :wikitext, '>= 0.6'
depend :remote, :command, 'monit'

role :app,              'rails.wincent.com'
role :web,              'rails.wincent.com'
role :db,               'rails.wincent.com', :primary => true

# allows us to do, for example: "cap staging deploy"
desc 'target the staging environment'
task :staging do
  set :application,       'kreacher.wincent.com'
  set :deploy_to,         "/var/www/#{application}"
  # TODO: copying database config will be different for each app, I think
end

desc 'target the production environent'
task :production do
  set :application,       'rails.wincent.com'
  set :deploy_to,         "/var/www/#{application}"
end

namespace :deploy do
  desc 'Set up links in "public" to persistent folders'
  task :public_links do
    run <<-CMD
      cd #{release_path} &&
      ln -s #{shared_path}/persisent #{release_path}/public/persistent
    CMD
  end
end
after 'deploy:update_code', 'deploy:public_links'

# for this task to work we must:
#   1. do "cap setup"
#   2. copy database.yml file to shared/config
#   3. do "cap deploy:cold"
task :after_symlink, :roles => :app do
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

desc 'Run all specs'
task :spec, :roles => :app do
  run "spec #{release_path}/spec"
end
before 'deploy:symlink', :spec
