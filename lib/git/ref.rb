require 'git'

module Git
  # Abstract superclass for concrete subclasses, Branch and Tag.
  class Ref
    # Raised when the output of "git for-each-ref" contained unexpected
    # input.
    class RefParseError < Exception
      def self.new_with_line line
        new "#{self}: ref parse error for line: #{line}"
      end
    end

    attr_reader :name, :repo, :sha1

    # Takes a string containing output from "git for-each-ref",
    # and returns an array of Ref objects, each encapsulating one line
    # from the string.
    def self.refs_array_from_string str, repo
      str.lines.map do |line|
        sha1, type, name = line.chomp.split
        case type
        when 'commit'
          if name =~ %r{\Arefs/tags/.+} # lightweight tag
            Tag.new repo, name, sha1, :lightweight => true
          else name =~ %r{\Arefs/heads/.+} # branch head
            Branch.new repo, name, sha1
          end
        when 'tag' # annotated tag object
          Tag.new repo, name, sha1
        end or raise RefParseError.new_with_line(line)
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

    # options is currently ignored by the Ref class but may be
    # used by subclasses (see the Tag class for an example).
    def initialize repo, name, sha1, options = {}
      @repo         = repo # Git::Repo instance
      @name         = name # eg. refs/heads/*, refs/tags/*
      @sha1         = sha1 # 40-character SHA-1 hash string
    end

    # Returns up to 20 commits starting at the Ref.
    def commits # options = {} # forthcoming
      Commit.log self
    end
  end # class Ref
end # module Git
