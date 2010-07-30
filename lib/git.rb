# The Git module provides a number of classes that do the real interaction
# with Git repos on disk (the model Repo class is really intended to be just a
# a simple ActiveRecord subclass, to expose the repo at the application level).

module Git
  # Raised when no repository found at a specified path.
  class NoRepositoryError < Exception; end

  # Raised when unexpected format encountered while parsing a raw commit object.
  class MalformedCommitError < Exception
    def self.new_with_line line
      self.new "#{self}: malformed commit object with line: #{line}"
    end
  end

  class ChildProcessError < Exception
    # Wopen3::Result instance which can be queried for status, stdout and
    # stderr.
    attr_accessor :result

    # Convenience method for creating a new exception with a suitable message
    # and setting up its Wopen3::Result instance.
    def self.new_with_result result
      message = "#{self}: non-zero exit status (#{result.status}) for args: " +
        result.args.join(' ')
      exception = self.new message
      exception.result = result
      exception
    end
  end

  # Raised when a 'git' command that was expected to succeed fails with a
  # non-zero exit status.
  class CommandError < ChildProcessError; end

  autoload :Branch, 'git/branch'
  autoload :Commit, 'git/commit'
  autoload :Ref, 'git/ref'
  autoload :Repo, 'git/repo'
  autoload :Tag, 'git/tag'
end # module Git
