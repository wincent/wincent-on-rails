require 'git'

module Git
  class Branch < Ref
    def self.all repo
      # refs/heads/*, not refs/remotes/origin/* etc
      result = repo.r_git 'show-ref', '--heads'
      refs_array_from_string result.stdout, repo
    end
  end # class Branch
end # module Git
