require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/index' do
  include IssuesHelper

  before do
    assigns[:issues] = [create_issue]
  end

  def do_render
    render '/issues/index'
  end

  it 'should have an "all issues" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', issues_path
    end
  end

  it 'should have a search link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a', 'search' # this is a complex JS link, so won't try too hard to test the actual onclick attribute
    end
  end

  it 'should have a "new issue" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', new_issue_path
    end
  end

  it 'should render the search form partial' do
    template.expect_render :partial => 'issues/search'
    do_render
  end

  it 'should show the scope info' do
    template.should_receive(:scope_info)
    do_render
  end

  it 'should render the issues list partial' do
    template.expect_render :partial => 'issues/issues'
    do_render
  end
end
