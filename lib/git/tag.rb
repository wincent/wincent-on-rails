require 'git'

module Git
  class Tag < Ref
    attr_reader :lightweight

    # Returns a list of tags, sorted in reverse chronological order (sorted by
    # taggerdate).
    #
    # Both annotated and lightweight tags are returned as Tag instances, but
    # with two distinctions:
    #
    #   - for annotated tags, the SHA-1 hash is corresponds to the tag object
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

    def initialize repo, name, sha1, options = {}
      super
      @lightweight  = options[:lightweight].nil? ? false : options[:lightweight]
    end
  end # class Tag
end # module Git
