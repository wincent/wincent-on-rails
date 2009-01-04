require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/index' do
  it 'should render the "form" partial' do
    template.should_receive :render, :partial => 'search/form'
    render '/search/index'
  end
end
