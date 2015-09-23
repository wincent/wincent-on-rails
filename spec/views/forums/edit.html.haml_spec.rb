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
    mock(view).render 'shared/error_messages', model: @forum
    render
  end

  it 'has a form for the forum' do
    render
    puts response.body
    within("form[action='#{forum_path(@forum)}']") do |form|
      expect(form).to have_css('input[name=_method][value=patch]')
      expect(form).to have_css("input[type=text][name='forum[name]']")
      expect(form).to have_css("input[type=text][name='forum[permalink]']")
      expect(form).to have_css("input[type=text][name='forum[description]']")
      expect(form).to have_css("input[type=text][name='forum[position]']")
      expect(form).to have_css("input[type=checkbox][name='forum[public]']")
      expect(form).to have_css('input[type=submit][value="Update Forum"]')
    end
  end

  it 'has a "show" link' do
    render
    expect(rendered).to have_link('show', href: forum_path(@forum))
  end

  it 'has an "all forums" link' do
    render
    expect(rendered).to have_link('all forums', href: '/forums')
  end
end
