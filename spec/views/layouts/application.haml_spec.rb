require 'spec_helper'

describe 'layouts/application' do
  it 'has a search form' do
    render
    rendered.should have_selector('form', :action => search_path, :method => 'get') do |form|
      form.should have_selector('input[name=q][type=text]')
    end
  end
end
