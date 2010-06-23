require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/layouts/application' do
  it 'should have a search form' do
    render '/layouts/application'
    response.should have_tag('form[action=?]', search_index_path) do
      with_tag 'input[name=query][type=text]'
    end
  end
end
