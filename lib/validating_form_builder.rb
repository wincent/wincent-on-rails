# FormBuilder subclass that inlines validation error messages
class ValidatingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field field, *args, &block
    super
  end
end # class ValidatingFormBuilder
