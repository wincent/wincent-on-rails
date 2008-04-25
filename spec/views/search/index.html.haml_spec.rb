require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/index' do
  it 'should render the "form" partial' do
    template.expect_render :partial => 'search/form'
    render '/search/index'
  end
end
