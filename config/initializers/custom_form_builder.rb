ActiveSupport.on_load(:action_view) do
  # alas, can't pass a string here to get lazy loading behavior due to this bug:
  # https://github.com/rails/rails/issues/12111
  self.default_form_builder = 'CustomFormBuilder'

  # workaround stolen from:
  # http://calvinconaway.com/2011/11/08/how-to-set-a-default-form-builder-in-rails-3-1-while-letting-it-be-autoloaded/
  ::ActionView::Helpers::FormHelper.class_eval do
    def form_for_with_custom(record, options = {}, &block)
      options[:builder] = CustomFormBuilder
      form_for_without_custom(record, options, &block)
    end
    alias_method_chain :form_for, :custom

    def fields_for_with_custom(record_name, record_object = nil, fields_options = {}, &block)
      fields_options[:builder] = CustomFormBuilder
      fields_for_without_custom(record_name, record_object, fields_options, &block)
    end
    alias_method_chain :fields_for, :custom
  end
end
