ActiveSupport.on_load(:action_view) do
  # auto-loading doesn't work here; perhaps it's too early in the boot sequence
  require 'custom_form_builder'

  # alas, can't pass a string here to get lazy loading behavior due to this bug:
  # https://github.com/rails/rails/issues/12111
  self.default_form_builder = CustomFormBuilder
end
