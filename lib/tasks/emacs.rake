namespace :emacs do
  desc 'Update the TAGS file'
  task :ctags do
    # shamelessly hardcoded for my local development machine
    # (want to pick up custom ctags, not system one)
    system '/usr/local/bin/ctags', '-e', '--tag-relative', '-R', 'app', 'lib', 'vendor'
  end
end
