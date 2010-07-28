# The Git module provides a number of classes that do the real interaction
# with Git repos on disk (the model Repo class is really intended to be just a
# a simple ActiveRecord subclass, to expose the repo at the application level).

module Git
  class NoRepositoryError < Exception; end

  autoload :Repo, 'git/repo'
end # module Git
