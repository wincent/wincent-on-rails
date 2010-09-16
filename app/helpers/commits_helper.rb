module CommitsHelper
  def preimage_line_number_anchor line, file_number
    line_number_anchor file_number, line.preimage_line_number, 'pre'
  end

  def postimage_line_number_anchor line, file_number
    line_number_anchor file_number, line.postimage_line_number, 'post'
  end

  def line_number_anchor file_number, line_number, postfix
    anchor_name = "F#{file_number}L#{line_number}-#{postfix}"
    content_tag 'a', line_number, :href => "\##{anchor_name}", :id => anchor_name
  end

  def td_contents_for_line line
    if line.simple?
      contents = prefix_for_line(line) + line.segments.first[1]
    else
      segments = line.segments.map do |segment|
        kind, content = segment[0], segment[1]
        if kind == :context
          h content
        elsif kind == :added
          content_tag 'span', content, :class => 'added'
        elsif kind == :deleted
          content_tag 'span', content, :class => 'deleted'
        end
      end.join('')
      contents = (prefix_for_line(line) + segments).html_safe
    end
    content_tag 'pre', contents
  end

  def prefix_for_line line
    case line.kind
    when :context
      ' '
    when :added
      '+'
    when :deleted
      '-'
    end
  end
end # module CommitsHelper
