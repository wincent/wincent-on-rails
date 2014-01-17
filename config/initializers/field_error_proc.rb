# We don't want fields with validation errors wrapped in a "div" as this
# makes it harder to consistently style forms. Instead of adding a new wrapper
# element, we add the "field_with_errors" class to the existing tag.
ActionView::Base.field_error_proc = -> (html_tag, instance_tag) {
  error_class = 'field-with-errors'
  fragment    = Nokogiri::HTML.fragment(html_tag)
  element     = fragment.children.first
  klass       = element['class']

  if klass
    element['class'] = klass + " #{error_class}" unless klass == error_class
  else
    element['class'] = error_class
  end

  fragment.to_s.html_safe
}
