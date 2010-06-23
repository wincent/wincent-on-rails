require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/search/new' do
  it 'should render the "form" partial' do
    template.should_receive :render, :partial => 'search/form'
    render '/search/new'
  end
end
