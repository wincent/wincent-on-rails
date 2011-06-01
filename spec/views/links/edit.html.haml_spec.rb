require 'spec_helper'

describe 'links/edit' do
  before do
    @link = Link.make!
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'renders the error messages partial' do
    stub.proxy(view).render
    mock(view).render 'shared/error_messages', :model => @link
    render
  end

  it 'has a form for the link' do
    render
    rendered.should have_css('form', :action => link_path(@link)) do |form|
      form.should have_css('input[name=_method][value=put]')
      form.should have_css('input[type=text]', :name => 'link[uri]')
      form.should have_css('input[type=text]', :name => 'link[permalink]')
      form.should have_css('input[type=submit][value="Update Link"]')
    end
  end

  it 'has an "all links" link' do
    render
    rendered.should have_css('.links a', :href => '/links', :content => 'all links')
  end
end
