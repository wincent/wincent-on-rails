require 'spec_helper'

describe 'layouts/application' do
  it 'has a search form' do
    render
    rendered.should have_selector('form', :action => searches_path, :method => 'post') do |form|
      form.should have_selector('input[name=query][type=text]')
    end
  end
end
