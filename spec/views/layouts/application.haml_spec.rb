require File.dirname(__FILE__) + '/../../spec_helper'

describe '/layouts/application' do
  it 'should have a search form' do
    render '/layouts/application'
    response.should have_tag('form[action=?]', search_index_url) do
      with_tag 'input[name=query][type=text]'
    end
  end
end
