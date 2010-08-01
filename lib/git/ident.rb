module Git
  class Ident
    attr_reader :name, :email, :time

    # @param ident should be either 'committer' or 'author'
    def self.parse_ident line, ident
      line.match(/\A#{ident} (.+) <(.+)> (\d+) ([+-]\d{4})\z/) or
        raise Git::MalformedCommitError.new_with_line(line)
      name  = $~[1]
      email = $~[2]
      time  = time_from_timestamp_and_offset $~[3], $~[4]
      self.new name, email, time
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

      # TODO: suspect I'm doing this offset thing wrong, so review it
      Time.at timestamp.to_i +
        (hours * 3600) +
        (minutes * 60)
    end

    def initialize name, email, time
      @name   = name
      @email  = email
      @time   = time
    end
  end # class Ident
end # module Git
