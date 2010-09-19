require 'git'

module Git
  class Tag < Ref
    # Raised when the output of "git cat-file tag" contains unexpected
    # input.
    class TagParseError < Exception
      def self.new_with_line line
        new "#{self}: tag parse error for line: #{line}"
      end
    end

    attr_reader :lightweight

    # Returns a list of tags, sorted in reverse chronological order (sorted by
    # taggerdate).
    #
    # Both annotated and lightweight tags are returned as Tag instances, but
    # with two distinctions:
    #
    #   - for annotated tags, the SHA-1 hash corresponds to the tag object
    #     itself; for lightweight tags, the SHA-1 hash corresponds to the
    #     associated commit
    #   - for lightweight tags, the +lightweight+ attribute is set to true
    #
    # Lightweight tags will appear at the end of the list, because they do not
    # have an associated taggerdate.
    def self.all repo
      result = repo.r_git 'for-each-ref', '--sort=-taggerdate', 'refs/tags'
      refs_array_from_string result.stdout, repo
    end

    # Returns a Tag instance for the tag referenced by refs/heads/name
    def self.tag name, repo
      result = repo.r_git 'for-each-ref', "refs/tags/#{name}"
      (refs_array_from_string result.stdout, repo).first or
        raise NonExistentRefError, "refs/tags/#{name} does not exist"
    end

    def initialize repo, name, sha1, options = {}
      super
      @lightweight  = options[:lightweight].nil? ? false : options[:lightweight]
    end

    # Returns the commit instance associated with this tag.
    def commit
      @commit ||= @lightweight ?
        Commit.commit_with_hash(@sha1, @repo) :
        annotated_commit
    end

    # Returns the annotation message for the receiver.
    #
    # Lightweight tags by definition do not have any annotation, so for
    # lightweight tags this method returns nil.
    def annotation
      if !@lightweight && !@annotation
        commit # reading the associated commit loads the annotation
      end
      @annotation
    end

  private

    def annotated_commit
      result = @repo.r_git 'cat-file', 'tag', @sha1
      lines = result.stdout.lines.entries

      sha1 = parse_object_line lines.shift
      parse_type_line lines.shift
      parse_tag_line lines.shift
      parse_tagger_line lines.shift
      @annotation = parse_annotation lines

      Commit.commit_with_hash sha1, @repo
    end

    def parse_object_line line
      raise TagParseError if line.nil?
      line = line.chomp
      raise TagParseError.new_with_line(line) unless
        line.match(/\Aobject ([a-f0-9]{40})\z/)
      $~[1]
    end

    def parse_type_line line
      raise TagParseError if line.nil?
      line = line.chomp
      raise TagParseError.new_with_line(line) unless line == 'type commit'
    end

    def parse_tag_line line
      raise TagParseError if line.nil?
      line = line.chomp
      raise TagParseError.new_with_line(line) unless
        line.match(/\Atag .+\z/)
    end

    def parse_tagger_line line
      raise TagParseError if line.nil?
      line = line.chomp
      raise TagParseError.new_with_line(line) unless
        line.match(/\Atagger .+\z/)
    end

    def parse_annotation lines
      raise TagParseError unless lines.shift  # skip separator line
      lines.join.chomp
    end
  end # class Tag
end # module Git
