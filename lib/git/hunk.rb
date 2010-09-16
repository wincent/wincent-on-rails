module Git
  class Hunk
    class Line
      # "kind" is either :added, :deleted, :context
      attr_reader :kind

      attr_reader :preimage_line_number, :postimage_line_number, :segments

      def self.addition_line_from_segments line_number, segments
        line_from_segments nil, line_number, segments, :excluded => :deleted
      end

      def self.deletion_line_from_segments line_number, segments
        line_from_segments line_number, nil, segments, :excluded => :added
      end

      class << self
      private
        def line_from_segments preimage_line_number, postimage_line_number, segments, options
          Line.new preimage_line_number, postimage_line_number, segments, options
        end
      end

      # @param [Fixnum] line_number
      # @param [String, Array] line_or_segments
      # @param [Hash] options
      def initialize preimage_line_number, postimage_line_number, line_or_segments = nil, options = {}
        @preimage_line_number = preimage_line_number
        @postimage_line_number = postimage_line_number
        @segments = []
        line_or_segments.to_a.each do |line|
          self.add_segment line, options
        end

        # implicit kind-setting in the << method won't work for lines which
        # contain only context; such as the deletion line here:
        #
        #   -var = 1
        #   +var = 1 # new comment
        case options[:excluded]
        when :deleted
          @kind = :added
        when :added
          @kind = :deleted
        end

        # for pure lines, may need to set to nil one of the line numbers
        case @kind
        when :deleted
          @postimage_line_number = nil
        when :added
          @preimage_line_number = nil
        end
      end

      def << segment
        @kind = segment.first if @kind == :context or @kind.nil?
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

      def add_segment segment, options = {}
        case segment
        when /\A\+(.*)/
          self << [:added, $~[1]] unless options[:excluded] == :added
        when /\A-(.*)/
          self << [:deleted, $~[1]] unless options[:excluded] == :deleted
        when /\A (.*)/
          self << [:context, $~[1]]
        end
      end
    end # class Line

    attr_reader :header, :preimage_start, :preimage_length,
      :postimage_start, :postimage_length, :lines

    def self.hunks_from_diff lines
      hunks = []
      while line = lines.first and line.match /\A@@/
        hunks << process_hunk(lines)
      end
      hunks
    end

    def self.process_hunk lines
      hunk = []
      header = lines.shift.chomp

      # length may be omitted if it is 1
      header.match(/\A@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@.*\z/) or
        raise Commit::MalformedDiffError.new_with_line(header)
      preimage_start = $~[1].to_i
      preimage_length = $~[2] ? $~[2].to_i : 1
      postimage_start = $~[3].to_i
      postimage_length = $~[4] ? $~[4].to_i : 1
      preimage_cursor = preimage_start
      postimage_cursor = postimage_start

      while line = lines.first and line.match(/\A[ ~+-]/)
        segments = []
        while segment = lines.first and segment.match(/\A[ +-]/)
          segments << lines.shift.chomp
        end
        case segments.length
        when 0
          raise Commit::MalformedDiffError.new_with_line(line) unless
            line.chomp == '~'
          lines.shift
        when 1  # "pure" addition, deletion or context
          hunk << (line = Line.new(preimage_cursor, postimage_cursor, line))
          if line.kind == :added
            postimage_cursor +=1
          elsif line.kind == :deleted
            preimage_cursor +=1
          else
            preimage_cursor += 1
            postimage_cursor += 1
          end
        else    # mixed; will require a deletion line and an addition line
          hunk << Line.deletion_line_from_segments(preimage_cursor, segments)
          hunk << Line.addition_line_from_segments(postimage_cursor, segments)
          preimage_cursor += 1
          postimage_cursor += 1
        end
      end

      new preimage_start, preimage_length,
        postimage_start, postimage_length, hunk, header
    end

    def initialize preimage_start, preimage_length,
        postimage_start, postimage_length, hunk, header
      @preimage_start = preimage_start
      @preimage_length = preimage_length
      @postimage_start = postimage_start
      @postimage_length = postimage_length
      @lines = hunk
      @header = header
    end
  end # class Hunk
end # module Git
