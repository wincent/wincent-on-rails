require 'spec_helper'

describe 'layouts/application' do
  it 'has a search form' do
    render
    within("section.search form[action='#{search_path}'][method='get']") do |form|
      expect(form).to have_css('input[name=q][type=text]')
    end
  end
end
