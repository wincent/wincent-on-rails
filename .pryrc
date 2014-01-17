if Object.const_defined? :Rails
  unless Rails.env.production?
    require "#{Rails.root}/spec/support/factory_girl"

    # based on: https://github.com/pry/pry/wiki/FAQ#wiki-hirb
    require 'hirb'

    Hirb::View.instance_eval do
      def enable_output_method
        @output_method  = true
        @old_print      = Pry.config.print
        Pry.config.print = proc do |output, value|
          Hirb::View.view_or_page_output(value) || @old_print.call(output, value)
        end
      end

      def disable_output_method
        Pry.config.print = @old_print
        @output_method = nil
      end
    end

    Hirb.enable
  end
end
