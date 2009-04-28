require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/index' do
  include IssuesHelper

  before do
    assigns[:issues] = [create_issue]
  end

  def do_render
    pending # url_for in lib/sortable.rb raises routing error
    # :controller => 'issues', :action => 'index'
    # (ok, but :protocol => 'https' is suppressed, which causes failure)
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

  it 'should hide the search div upon initial display' do
    do_render
    response.should have_tag('div#issue_search[style=?]', /display:none;/)
  end

  it 'should have a "new issue" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', new_issue_path
    end
  end

  it 'should have a "support overview" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', support_path
    end
  end

  it 'should render the search form partial' do
    template.should_receive :render, :partial => 'issues/search'
    do_render
  end

  it 'should show the scope info' do
    template.should_receive(:scope_info)
    do_render
  end

  it 'should render the issues list partial' do
    template.should_receive :render, :partial => 'issues/issues'
    do_render
  end
end
