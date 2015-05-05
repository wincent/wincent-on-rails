ActiveSupport.on_load(:action_view) do
  # alas, can't pass a string here to get lazy loading behavior due to this bug:
  # https://github.com/rails/rails/issues/12111
  self.default_form_builder = 'CustomFormBuilder'

  # workaround stolen from:
  # http://calvinconaway.com/2011/11/08/how-to-set-a-default-form-builder-in-rails-3-1-while-letting-it-be-autoloaded/
  ::ActionView::Helpers::FormHelper.class_eval do
    def form_for_with_custom(record, options = {}, &block)
      options[:builder] ||= CustomFormBuilder

      # append a field: http://stackoverflow.com/a/2112364
      # for catching spam: http://davidwalsh.name/wordpress-comment-spam
      form_for_without_custom(record, options) do |f|
        if options[:honey_pot] != false
          concat(text_field_tag('website_address', '', class: 'website-address'))
        end
        proc.call(f)
      end
    end
    alias_method_chain :form_for, :custom

    def fields_for_with_custom(record_name, record_object = nil, fields_options = {}, &block)
      fields_options[:builder] ||= CustomFormBuilder
      fields_for_without_custom(record_name, record_object, fields_options, &block)
    end
    alias_method_chain :fields_for, :custom
  end
end
