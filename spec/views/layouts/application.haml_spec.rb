require 'spec_helper'

describe 'layouts/application' do
  it 'has a search form' do
    render
    within("form[action='#{search_path}'][method='get']") do |form|
      form.should have_css('input[name=q][type=text]')
    end
  end
end
