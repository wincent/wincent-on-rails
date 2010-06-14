# We don't want fields with validation errors wrapped in a "div" as this
# makes it harder to consistently style forms. Instead of adding a new wrapper
# element, we add the "field_with_errors" class to the existing tag.
# We'll be called once for the label and once for the form field.
# The parsing is brittle in the sense that it depends on Rails not ever passing
# us any malformed tags.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  error_class = 'field_with_errors'
  if html_tag.sub!(/\A(<[^>]+ class=["'])/, '\1 ' + error_class)
    html_tag.html_safe
  else
    html_tag.sub(/\A(<\w+)/, '\1 class="' + error_class + '"').html_safe
  end
end
