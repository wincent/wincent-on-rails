module Git
  class Ident
    attr_reader :name, :email, :time

    # @param ident should be either 'committer' or 'author'
    def self.parse_ident line, ident
      line.match(/\A#{ident} (.+) <(.+)> (\d+) ([+-]\d{4})\z/) or
        raise Git::Commit::MalformedCommitError.new_with_line(line)
      name  = $~[1]
      email = $~[2]
      time  = time_from_timestamp_and_offset $~[3], $~[4]
      self.new name, email, time
    end

    # Takes a UNIX epoch timestamp in seconds and a time zone offset and
    # produces the corresponding Time object in the local time zone.
    #
    # The offset is expected to be a string of the form "+xxyy" or "-xxyy",
    # where "xx" is a number of hours and "yy" is a number of minutes.
    def self.time_from_timestamp_and_offset timestamp, offset
      # offset ignored, UNIX timestamps by definition are in UTC
      Time.at timestamp.to_i
    end

    def initialize name, email, time
      @name   = name
      @email  = email
      @time   = time
    end

    # Provides a generic Ident instance of the receiver.
    #
    # This is useful for comparing a Committer and an Author to see
    # if they refer to the same person:
    #
    #     author.to_ident == committer.to_ident # => true
    def to_ident
      if self.class == Ident
        self
      else
        Ident.new @name, @email, @time
      end
    end

    def == other
      other.class == self.class &&
        other.name == @name &&
        other.email == @email &&
        other.time == @time
    end
  end # class Ident
end # module Git
