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
    mock(view).render 'shared/error_messages', model: @link
    render
  end

  it 'has a form for the link' do
    render
    within("form.edit_link[action='#{link_path(@link)}']") do |form|
      expect(form).to have_css('input[name=_method][value=patch]')
      expect(form).to have_css('input[type=text][name="link[uri]"]')
      expect(form).to have_css('input[type=text][name="link[permalink]"]')
      expect(form).to have_css('input[type=submit][value="Update Link"]')
    end
  end

  it 'has an "all links" link' do
    render
    expect(rendered).to have_link('all links', href: links_path)
  end
end
