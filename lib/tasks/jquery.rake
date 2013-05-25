namespace :jquery do
  # First-run pre-requisites (taken mostly from the jQuery README.md):
  #
  #   git submodule update --init
  #   brew install git node
  #   npm install -g grunt-cli
  #
  # NOTE: A homebrew install of node/npm will place executables in
  # /usr/local/share/npm/bin, so that needs to be in the PATH in order for grunt
  # to work.
  #
  task :build do
    system 'cd vendor/assets/javascripts/jquery && npm install && grunt custom:-deprecated,-event-alias dist:..'
  end
end
