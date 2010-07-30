module Git
  class Commit
    # attributes, in the order that they appear in "git log --format=raw"
    attr_reader :sha1, :tree, :parents, :author, :committer, :message

    # "other" headers
    attr_reader :headers

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
        line.match(/\Acommit ([a-f0-9]{40})\z/) or
          raise Git::MalformedCommitError.new_with_line(line)
        commit = $~[1]
        line = lines.shift.chomp
        line.match(/\Atree ([a-f0-9]{40})\z/) or
          raise Git::MalformedCommitError.new_with_line(line)
        tree = $~[1]
        parents = []
        while line = lines.shift.chomp and line.match(/\Aparent ([a-f0-9]{40})\z/)
          parents << $~[1]
        end
        line.match(/\Aauthor (.+) <(.+)> (\d+) ([+-]\d{4})\z/) or
          raise Git::MalformedCommitError.new_with_line(line)
        author_name = $~[1]
        author_email = $~[2]
        author_time = time_from_timestamp_and_offset $~[3], $~[4]
        line = lines.shift.chomp
        line.match(/\Acommitter (.+) <(.+)> (\d+) ([+-]\d{4})\z/) or
          raise Git::MalformedCommitError.new_with_line(line)
        committer_name = $~[1]
        committer_email = $~[2]
        committer_time = time_from_timestamp_and_offset $~[3], $~[4]
        line = lines.shift.chomp
        line.match(/\Aencoding (.+)\z/) # optional
        encoding = $~[1] if $~
        line = lines.shift.chomp
        raise Git::MalformedCommitError.new_with_line(line) unless line == ''
        message = []
        while line = lines.shift and line.match(/\A {4}(.+)\n\z/)
          message = $~[1]
        end
        commits << self.new :commit           => commit,
                            :tree             => tree,
                            :parents          => parents,
                            :author_name      => author_name,
                            :author_email     => author_email,
                            :author_time      => author_time,
                            :committer_name   => committer_name,
                            :committer_email  => committer_email,
                            :committer_time   => committer_time,
                            :encoding         => encoding,
                            :message          => message.join("\n")
        if line
          raise Git::MalformedCommitError.new_with_line(line) unless line == ''
        else
          break
        end
      end
    end

    # Takes a UNIX epoch timestamp in seconds and a time zone offset and
    # produces the corresponding Time object.
    #
    # The offset is expected to be a string of the form "+xxyy" or "-xxyy",
    # where "xx" is a number of hours and "yy" is a number of minutes.
    def self.time_from_timestamp_and_offset timestamp, offset
      timestamp = timestamp.to_i
      offset = offset.to_i
      hours = offset / 100
      minutes = offset.abs % 100 # for consistency, never do modulo on -ve num
      minutes *= -1 if hours < 0 # but restore signedness afterwards
      Time.at timestamp.to_i +
        (hours * 3600) +
        (minutes * 60)
    end

    def initialize attributes
      
    end
  end # class Commit
end # module Git
