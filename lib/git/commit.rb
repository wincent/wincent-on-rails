module Git
  class Commit
    # attributes, in the order that they appear in "git log --format=raw"
    attr_reader :commit, :tree, :parents, :author, :committer, :encoding,
      :message

    # Returns up to 20 commits starting at Ref.
    #
    # This is an efficient means of retrieving commits because it does so with
    # a single invocation of "git log". It is faster than retrieving individual
    # commits one ref at a time.
    def self.log ref # options = {} # forthcoming
      result  = ref.repo.r_git 'log', '--format=raw', '-n', '20', ref.name
      lines   = result.stdout.lines
      commits = []

      # see commit.c in git.git for details of the raw format
      while line = lines.shift.chomp do
        commit    = parse_commit line
        tree      = parse_tree lines.shift.chomp
        parents   = parse_parents lines
        author    = Author.parse_author lines.shift.chomp
        committer = Committer.parse_committer lines.shift.chomp
        encoding  = parse_encoding lines
        parse_separator lines.shift.chomp
        message   = parse_message lines
        commits << self.new(ref,
                            :commit     => commit,
                            :tree       => tree,
                            :parents    => parents,
                            :author     => author,
                            :committer  => committer,
                            :encoding   => encoding,
                            :message    => message.join("\n"))
        break if lines.empty?
        parse_separator lines.shift.chomp
      end
      commits
    end

    def initialize ref, attributes
      @ref        = ref
      @commit     = attributes[:commit]
      @tree       = attributes[:tree]
      @parents    = attributes[:parents]
      @author     = attributes[:author]
      @committer  = attributes[:committer]
      @encoding   = attributes[:encoding]
      @message    = attributes[:message]
    end

    class << self

    private

      def parse_commit line
        line.match(/\Acommit ([a-f0-9]{40})\z/) or
          raise Git::MalformedCommitError.new_with_line(line)
        $~[1]
      end

      def parse_tree line
        line.match(/\Atree ([a-f0-9]{40})\z/) or
          raise Git::MalformedCommitError.new_with_line(line)
        $~[1]
      end

      # Returns an array of SHA-1 commit ids representing the parent of the
      # commit. For root commits the returned array is empty.
      def parse_parents lines
        parents = []
        while line = lines.first.chomp and line.match(/\Aparent ([a-f0-9]{40})\z/)
          parents << $~[1]
          lines.shift
        end
        parents
      end

      def parse_encoding lines
        encoding = nil
        if lines.first.chomp.match(/\Aencoding (.+)\z/)
          encoding = $~[1]
          lines.shift
        end
        encoding
      end

      def parse_separator line
        raise Git::MalformedCommitError.new_with_line(line) unless line == ''
      end

      def parse_message lines
        message = []
        while line = lines.first and line.match(/\A {4}(.*)\n\z/)
          message << $~[1]
          lines.shift
        end
        message
      end
    end # class << self
  end # class Commit
end # module Git
