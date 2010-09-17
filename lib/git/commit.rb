module Git
  class Commit
    # Raised when unexpected format encountered while parsing a raw commit
    # object.
    class MalformedCommitError < Exception
      def self.new_with_line line
        self.new "#{self}: malformed commit object with line: #{line}"
      end
    end

    # Raised when unexpected format encountered while parsing output of "git
    # diff-tree".
    class MalformedDiffError < Exception
      def self.new_with_line line
        self.new "#{self}: malformed diff output for line: #{line}"
      end
    end

    # Raised when a commit is not reachable from any ref.
    class UnreachableCommitError < Exception
      def self.new_with_sha1 sha1
        self.new "#{self}: unreachable commit: #{sha1}"
      end
    end

    # Raised when commit does not exist.
    class NoCommitError < Exception
      def self.new_with_sha1 sha1
        self.new "#{self}: no commit found: #{sha1}"
      end
    end

    # attributes, in the order that they appear in "git log --format=raw"
    attr_reader :commit, :tree, :parents, :author, :committer, :encoding,
      :message

    # other attributes
    attr_reader :ref, :repo

    # Returns up to 20 commits starting at Ref.
    #
    # This is an efficient means of retrieving commits because it does so with
    # a single invocation of "git log". It is faster than retrieving individual
    # commits one ref at a time.
    def self.log ref # options = {} # forthcoming
      result  = ref.repo.r_git 'log', '--format=raw', '-n', '20', ref.name
      lines   = result.stdout.lines.entries
      commits = []

      # see commit.c in git.git for details of the raw format
      while line = lines.shift.chomp
        commit    = parse_commit line
        tree      = parse_tree lines.shift.chomp
        parents   = parse_parents lines
        author    = Author.parse_author lines.shift.chomp
        committer = Committer.parse_committer lines.shift.chomp
        encoding  = parse_encoding lines
        parse_separator lines.shift.chomp
        message   = parse_message lines
        commits << self.new(:ref        => ref,
                            :commit     => commit,
                            :tree       => tree,
                            :parents    => parents,
                            :author     => author,
                            :committer  => committer,
                            :encoding   => encoding,
                            :message    => message)
        break if lines.empty?
        parse_separator lines.shift.chomp
      end
      commits
    end

    def self.commit_with_hash sha1, repo
      result = repo.git 'name-rev', '--no-undefined', sha1
      raise UnreachableCommitError.new_with_sha1(sha1) unless result.success?
      result = repo.git 'cat-file', 'commit', sha1
      raise NoCommitError.new_with_sha1(sha1) unless result.success?
      lines   = result.stdout.lines.entries
      tree    = parse_tree lines.shift.chomp
      parents = parse_parents lines
      author  = Author.parse_author lines.shift.chomp
      committer = Committer.parse_committer lines.shift.chomp
      encoding  = parse_encoding lines
      parse_separator lines.shift.chomp
      message = lines.join
      new :repo       => repo,
          :commit     => sha1,
          :tree       => tree,
          :parents    => parents,
          :author     => author,
          :committer  => committer,
          :encoding   => encoding,
          :message    => message
    end

    def initialize attributes
      @ref        = attributes[:ref]
      @repo       = attributes[:repo] || @ref.repo
      @commit     = attributes[:commit]
      @tree       = attributes[:tree]
      @parents    = attributes[:parents]
      @author     = attributes[:author]
      @committer  = attributes[:committer]
      @encoding   = attributes[:encoding]
      @message    = attributes[:message]
    end

    def diff
      unless @diff
        result = @repo.r_git 'diff-tree', '--numstat', '-p',
          '--patience', '--root', @commit
        @diff = parse_diff result.stdout.lines.entries
      end
      @diff
    end

    # Returns the first line of the message.
    def subject
      @subject ||= @message.match(/\A.*$/)[0]
    end

    class << self

    private

      def parse_commit line
        line.match(/\Acommit ([a-f0-9]{40})\z/) or
          raise MalformedCommitError.new_with_line(line)
        $~[1]
      end

      def parse_tree line
        line.match(/\Atree ([a-f0-9]{40})\z/) or
          raise MalformedCommitError.new_with_line(line)
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
        raise MalformedCommitError.new_with_line(line) unless line == ''
      end

      def parse_message lines
        message = []
        while line = lines.first and line.match(/\A {4}(.*)\n\z/)
          message << $~[1]
          lines.shift
        end
        message.join("\n")
      end
    end # class << self

  private

    def parse_diff lines
      line = lines.shift.chomp
      raise MalformedDiffError.new_with_line(line) unless line == @commit
      changes = parse_numstat lines
      line = lines.shift.chomp
      raise MalformedDiffError.new_with_line(line) unless line == ''
      changes.each { |change| parse_file_diff change, lines }
      changes
    end

    def parse_numstat lines
      changes = []
      while line = lines.first.chomp and line.match(/\A(\d+|-)\t(\d+|-)\t(.+)\z/)
        changes << {
          :added    => $~[1] == '-' ? nil : $~[1].to_i, # binary file: - (nil)
          :deleted  => $~[2] == '-' ? nil : $~[2].to_i, # binary file: - (nil)
          :path     => $~[3]
        }
        lines.shift
      end
      changes
    end

    def parse_file_diff change, lines
      parse_git_diff_header lines.shift.chomp
      parse_extended_headers lines
      parse_from_to_header lines
      change[:hunks] = parse_hunks lines
    end

    def parse_git_diff_header line
      raise MalformedDiffError.new_with_line(line) unless
        line.match(%r{\Adiff --git ("a/.+"|a/.+) ("b/.+"|b/.+)\z})
    end

    def parse_extended_headers lines
      # not really "parsing" these at all for now, just skipping over them
      header_patterns = [
        /\Aold mode (.+)\z/,
        /\Anew mode (.+)\z/,
        /\Adeleted file mode (.+)\z/,
        /\Anew file mode (.+)\z/,
        /\Acopy from (.+)\z/,
        /\Acopy to (.+)\z/,
        /\Arename from (.+)\z/,
        /\Arename to (.+)\z/,
        /\Asimilarity index (.+)\z/,
        /\Adissimilarity index (.+)\z/,
        /\Aindex ([a-f0-9]+)\.\.([a-f0-9]+)( [0-7]+)?\z/
      ]
      while line = lines.first.chomp
        if header_patterns.any? { |pattern| line.match pattern }
          lines.shift
        else
          break
        end
      end
    end

    def parse_from_to_header lines
      # again, not really parsed, just skipped over
      line = lines.shift.chomp
      return if line.match(%r{\ABinary files .+ and .+ differ\z})
      line.match(%r{\A--- ("a/.+"|a/.+|/dev/null)\z}) or
        raise MalformedDiffError.new_with_line(line)
      line = lines.shift.chomp
      line.match(%r{\A\+\+\+ ("b/.+"|b/.+|/dev/null)\z}) or
        raise MalformedDiffError.new_with_line(line)
    end

    def parse_hunks lines
      Hunk.hunks_from_diff lines
    end
  end # class Commit
end # module Git
