require File.expand_path('../../spec_helper', File.dirname(__FILE__))

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
    rendered.should have_selector('form', :action => tag_path(@tag)) do |form|
      form.should have_selector('input[name=_method][value=put]')
      form.should have_selector('input', :type => 'text', :name => 'tag[name]')
      form.should have_selector('input[type=submit][value="Update Tag"]')
    end
  end

  it 'has a "show" link' do
    render
    rendered.should have_selector('.links a', :href => tag_path(@tag), :content => 'show')
  end

  it 'has a "destroy" link' do
    render
    rendered.should have_selector('.links form', :action=> tag_path(@tag)) do |form|
      form.should have_selector('input[name=_method][value=delete]')
      form.should have_selector('input[type=submit][data-confirm="Are you sure?"]')
    end
  end

  it 'has an "all tags" link' do
    render
    rendered.should have_selector('.links a', :href => tags_path, :content => 'all tags')
  end
end
