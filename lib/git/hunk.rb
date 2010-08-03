module Git
  class Hunk
    class Line
      # "type" is either :added, :deleted, :context
      attr_reader :type
      attr_reader :line_number, :segments

      def self.addition_line_from_segments line_number, segments
        line_from_segments line_number, segments, :excluded => :deleted
      end

      def self.deletion_line_from_segments line_number, segments
        line_from_segments line_number, segments, :excluded => :added
      end

      class << self
      private
        def self.line_from_segments line_number, segments, options
          line = Line.new line_number
          segments.each do |segment|
            line << segment if segment.first != options[:excluded]
          end
          line
        end
      end

      def initialize line_number, line = nil
        @line_number = line_number
        @segments = []
        self.line = line if line
      end

      def << segment
        @type = segment.first if @type == :context or @type.nil?
        @segments << segment
      end

      def empty?
        @segments.empty?
      end

      # A line is considered "simple" if it is "pure" (ie. contains only a
      # single addition, deletion or context element).
      def simple?
        @segments.length == 1
      end

    protected

      def line= line
        case line
        when /\A\+(.*)/
          self << [:added, $~[1]]
        when /\A\-(.*)/
          self << [:deleted, $~[1]]
        when /\A (.*)/
          self << [:context, $~[1]]
        end
      end
    end # class Line

    attr_reader :preimage_start, :preimage_length,
      :postimage_start, :postimage_length, :lines

    def self.hunks_from_diff lines
      hunks = []
      while line = lines.first and lines.match /\A@@/
        hunks << process_hunk lines
      end
      hunks
    end

    def self.process_hunk lines
      line = lines.shift.chomp
      hunk = []
      while line = lines.first.chomp and
        line.match(/\A@@ -(\d+),(\d+) \+(\d+),(\d+)@@.*\z/)
        preimage_start, preimage_length   = $~[1], $~[2]
        postimage_start, postimage_length = $~[3], $~[4]
        preimage_cursor = preimage_start
        postimage_cursor = postimage_start
        lines.shift
        segments = []
        while segment = lines.first and line.match(/\A[ +-]/)
          segments << lines.shift.chomp
        end
        case segments.length
        when 0
          raise MalformedDiffError.new
        when 1  # "pure" addition, deletion or context
          hunk << Line.new(preimage_cursor, line)
          preimage_cursor += 1
        else    # mixed; will require a deletion line and an addition line
          hunk << Line.deletion_line_from_segments(preimage_cursor, segments)
          hunk << Line.addition_line_from_segments(postimage_cursor, segments)
          preimage_cursor += 1
          postimage_cursor += 1
        end
      end
      new preimage_start, preimage_length,
        postimage_start, postimage_length, hunk
    end

    def initialize preimage_start, preimage_length,
        postimage_start, postimage_length, hunk
      @preimage_start = preimage_start
      @preimage_length = preimage_length
      @postimage_start = postimage_start
      @postimage_length = postimage_length
      @lines = hunk
    end
  end # class Hunk
end # module Git
