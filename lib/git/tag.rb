require 'git'

module Git
  # With --dereference we get this:
  #   b7c0a512124cb8f518a71fe60244af520b9ae4dc refs/tags/1.0.0.beta.2    <-- annotated tag object
  #   d35e54d5338e35407db194290feece410c8eb517 refs/tags/1.0.0.beta.2^{} <-- commit it points to
  #   b078098212de02f1505b4c73de0a2e8e68ee3d65 refs/tags/1.0.0.beta.3    <-- commit (no annotation object)
  # so need to model it with a hash
  class Tag < Ref
    def self.all repo
      result = repo.r_git 'show-ref', '--tags' # refs/tags/*
      refs_array_from_string result.stdout, repo
    end
  end # class Tag
end # module Git
