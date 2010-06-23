require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/search/issues' do
  def do_render
    render '/search/issues'
  end

  it 'should call the page title helper' do
    template.should_receive(:page_title).with('Issue search')
    do_render
  end

  it 'should have an "all issues" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', issues_path
    end
  end

  it 'should have a "support overview" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', support_path
    end
  end

  it 'should have a "site search" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', search_index_path
    end
  end

  it 'should render the search form partial' do
    template.should_receive :render, :partial => 'issues/search'
    do_render
  end
end
