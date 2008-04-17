require File.dirname(__FILE__) + '/../../spec_helper'

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

  it 'should render the search form partial' do
    template.expect_render :partial => 'issues/search'
    do_render
  end
end
