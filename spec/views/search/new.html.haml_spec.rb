require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/new' do
  it 'should render the "form" partial' do
    template.expect_render :partial => 'search/form'
    render '/search/new'
  end
end
