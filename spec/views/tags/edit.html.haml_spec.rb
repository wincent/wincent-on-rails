require 'spec_helper'

describe 'tags/edit' do
  before do
    @tag = Tag.make!
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'renders the error messages partial' do
    stub.proxy(view).render
    mock(view).render 'shared/error_messages', :model => @tag
    render
  end

  it 'has a form for the tag' do
    render
    rendered.should have_css('form', :action => tag_path(@tag)) do |form|
      form.should have_css('input[name=_method][value=put]')
      form.should have_css('input', :type => 'text', :name => 'tag[name]')
      form.should have_css('input[type=submit][value="Update Tag"]')
    end
  end

  it 'has a "show" link' do
    render
    rendered.should have_css('.links a', :href => tag_path(@tag), :content => 'show')
  end

  it 'has a "destroy" link' do
    pending 'implementation of tags#destroy action in controller'
    mock(view).button_to_destroy_model @tag
    render
  end

  it 'has an "all tags" link' do
    render
    rendered.should have_css('.links a', :href => '/tags', :content => 'all tags')
  end
end
