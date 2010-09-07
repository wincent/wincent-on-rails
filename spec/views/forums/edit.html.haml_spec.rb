require 'spec_helper'

describe 'forums/edit' do
  before do
    @forum = Forum.make!
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'renders the error messages partial' do
    stub.proxy(view).render
    mock(view).render 'shared/error_messages', :model => @forum
    render
  end

  it 'has a form for the forum' do
    render
    rendered.should have_selector('form', :action => forum_path(@forum)) do |form|
      form.should have_selector('input[name=_method][value=put]')
      form.should have_selector('input[type=text]', :name => 'forum[name]')
      form.should have_selector('input[type=text]', :name => 'forum[permalink]')
      form.should have_selector('input[type=text]', :name => 'forum[description]')
      form.should have_selector('input[type=text]', :name => 'forum[position]')
      form.should have_selector('input[type=checkbox]', :name => 'forum[public]')
      form.should have_selector('input[type=submit][value="Update Forum"]')
    end
  end

  it 'has a "show" link' do
    render
    rendered.should have_selector('.links a', :href => forum_path(@forum), :content => 'show')
  end

  it 'has an "all forums" link' do
    render
    rendered.should have_selector('.links a', :href => '/forums', :content => 'all forums')
  end
end
