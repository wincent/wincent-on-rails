# without this we don't get password prompts from Git
default_run_options[:pty] = true

set :application,       'rails.wincent.com'

# note that the application is in a subdir of the repository
# so we need to set up NGinx to look for public files at:
#   #{current_path}/wincent_on_rails/public
# and Mongrel needs to know that the app root is actually:
#   #{current_path}/wincent_on_rails
set :repository,        'user@host:/pub/git/private/wincent.com'
set :branch,            'origin/maint'

set :deploy_to,         "/var/www/#{application}"
set :scm,               :git

# the SSH user
set :user,              'wincent.com'

role :app,              'rails.wincent.com'
role :web,              'rails.wincent.com'
role :db,               'rails.wincent.com', :primary => true

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

desc 'Run all specs'
task :spec, :roles => :app do
  run "spec #{release_path}/spec"
end
before 'deploy:symlink', :spec
