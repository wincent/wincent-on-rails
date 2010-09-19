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

    # Returns a Branch instance for the branch referenced by refs/heads/name
    def self.branch name, repo
      result = repo.r_git 'for-each-ref', "refs/heads/#{name}"
      (refs_array_from_string result.stdout, repo).first or
        raise NonExistentRefError, "refs/heads/#{name} does not exist"
    end
  end # class Branch
end # module Git
