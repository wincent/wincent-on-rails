require 'git'

module Git
  class Branch < Ref
    # Returns a list of branches, sorted in reverse chronological order
    # (sorted by committerdate).
    def self.all repo
      # refs/heads/*, not refs/remotes/origin/* etc
      result = repo.r_git 'for-each-ref', '--sort=-committerdate', 'refs/heads'
      refs_array_from_string result.stdout, repo
    end
  end # class Branch
end # module Git
