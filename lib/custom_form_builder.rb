class CustomFormBuilder < ActionView::Helpers::FormBuilder
  UNWRAPPAPLE_HELPERS = %i[hidden_field fields_for label]
  WRAPPABLE_HELPERS   = field_helpers - UNWRAPPAPLE_HELPERS
  ADDITIONAL_HELPERS  = %i[select]

  # Overwrite the wrappable helper methods (text_field, select etc) to produce a
  # method that generates markup like this:
  #
  #   <div class="field-row">
  #     <label for="issue_summary">
  #       <div class="label-text">Summary</div>
  #       <!-- superclass's original input here -->
  #       <aside class="annotation">enter as much detail as possible</aside)
  #     </label>
  #   </div>
  #
  (WRAPPABLE_HELPERS + ADDITIONAL_HELPERS).each do |name|
    define_method(name) do |attr, *args|
      options    = args.extract_options!
      annotation = annotation(options.delete(:annotation))
      label_text = label_text(options.delete(:label) || attr.to_s.humanize)

      @template.content_tag(:div, class: 'field-row') do
        @template.content_tag(:label) do
          @template.safe_join([
            label_text,
            super(attr, *args, options),
            annotation,
          ], '')
        end
      end
    end
  end

private

  def label_text(label_text)
    @template.content_tag(:div, label_text, class: 'label-text')
  end

  def annotation(annotations)
    return '' unless annotations

    @template.safe_join(Array(annotations).map do |annotation|
      @template.content_tag(:aside, annotation, class: 'annotation')
    end, ' ')
  end
end
