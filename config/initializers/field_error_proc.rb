# We don't want fields with validation errors wrapped in a "div" as this
# makes it harder to consistently style forms. Instead of adding a new wrapper
# element, we add the "field_with_errors" class to the existing tag.
# We'll be called once for the label and once for the form field.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  error_class = 'field_with_errors'
  html_tag = html_tag.to_str # can't sub! on ActiveSupport::SafeBuffer

  # first try appending to existing class attribute,
  # otherwise fallback to adding new class attribute
  html_tag.sub!(/\A(<[^>]+ class=["'])/, %Q[\\1#{error_class} ]) ||
    html_tag.sub!(/\A(<\w+)/, %Q[\\1 class="#{error_class}"])
  html_tag.html_safe
end
