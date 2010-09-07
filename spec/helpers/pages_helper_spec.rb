require 'spec_helper'

describe PagesHelper do
  describe '#button_to_destroy_page' do
    it 'delegates to #button_to_destroy_model' do
      product = Product.make! :permalink => 'foo'
      page = Page.make! :product => product, :permalink => 'bar'
      mock(helper).button_to_destroy_model page, '/products/foo/pages/bar'
      helper.button_to_destroy_page page
    end
  end
end
