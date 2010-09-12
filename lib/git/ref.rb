require 'git'

module Git
  # Abstract superclass for concrete subclasses, Branch and Tag.
  class Ref
    attr_reader :name, :repo, :sha1

    # Takes a string containing output from "git show-ref", such as:
    #
    #   0785b65f3ebfb14498acd84f4d0b9e4ee7419006 refs/tags/0.3.1
    #   d2656c2f8aa70657aa3bd80a474069293338fab1 refs/tags/0.4.0
    #
    # and returns an array of Ref objects, each encapsulating one line
    # from the string.
    def self.refs_array_from_string str, repo
      # TODO: handle --dereference (useful for tags)
      str.lines.map do |line|
        sha1, name = line.chomp.split
        new repo, name, sha1
      end
    end

    # Return a Ref object which represents the HEAD of the repository.
    # This may actually be the same as an existing branch, or it may be
    # be a "detached head" with no corresponding ref.
    def self.head repo
      result = repo.r_git 'show-ref', '--head'
      head = result.stdout.lines.find do |line| # usually (always?) the first line
        line.chomp.split[1] == 'HEAD'
      end
      if head
        sha1, name = head.chomp.split
        new repo, name, sha1
      end
    end

    def initialize repo, name, sha1
      @repo = repo # Git::Repo instance
      @name = name # eg. refs/heads/*, refs/tags/*
      @sha1 = sha1 # 40-character SHA-1 hash string
    end

    # Returns up to 20 commits starting at the Ref.
    def commits # options = {} # forthcoming
      Commit.log self
    end
  end # class Ref
end # module Git
