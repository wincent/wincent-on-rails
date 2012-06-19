# install at:
#   /data/rails/deploy/shared/unicorn.rb
#
# start from monit with:
#   unicorn_rails -c /data/rails/deploy/shared/unicorn.rb -E production -D

worker_processes  4
listen            '/data/rails/deploy/shared/unicorn.sock'
working_directory '/data/rails/deploy/current'
preload_app       true
pid               '/data/rails/deploy/shared/pids/unicorn.pid'
stderr_path       '/data/rails/deploy/shared/log/unicorn.stderr.log'
stdout_path       '/data/rails/deploy/shared/log/unicorn.stdout.log'

before_fork do |server, worker|
  # master doesn't need connection to database
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

# don't use parents' sockets
after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
