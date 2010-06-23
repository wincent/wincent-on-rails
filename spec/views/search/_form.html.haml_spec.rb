require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/search/_form' do
  def do_render
    render :partial => '/search/form'
  end

  it 'should use the "search" style sheet' do
    template.should_receive(:stylesheet_link_tag).with('search')
    do_render
  end

  it 'should have an "issue tracker search" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', issues_search_path
    end
  end

  it 'should have an "tag search" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', search_tags_path
    end
  end

  it 'should show the search form' do
    do_render
    response.should have_tag('form[action=?]', search_index_path) do
      with_tag 'input[name=?]', 'query'
      with_tag 'input[type=?]', 'text'
      with_tag 'input[value=?]', 'Search'
      with_tag 'input[type=?]', 'submit'
    end
  end
end
