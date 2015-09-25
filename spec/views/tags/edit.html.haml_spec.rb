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
    mock(view).render 'shared/error_messages', model: @tag
    render
  end

  it 'has a form for the tag' do
    render
    within("form[action='#{tag_path(@tag)}']") do |form|
      expect(form).to have_css('input[name=_method][value=patch]')
      expect(form).to have_css('input[type="text"][name="tag[name]"]')
      expect(form).to have_css('input[type=submit][value="Update Tag"]')
    end
  end

  it 'has a "show" link' do
    render
    expect(rendered).to have_link('show', href: tag_path(@tag))
  end

  it 'has an "all tags" link' do
    render
    expect(rendered).to have_link('all tags', href: '/tags')
  end
end
