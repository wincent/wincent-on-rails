require 'spec_helper'

describe 'forums/show' do
  before do
    @name = Sham.random
    @forum = Forum.make! :name => @name
    @topics = []
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'shows the forum name as a major heading' do
    render
    rendered.should have_css('h1.major', text: @name)
  end
end
