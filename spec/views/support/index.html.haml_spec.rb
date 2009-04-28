require File.dirname(__FILE__) + '/../../spec_helper'

describe '/support/index' do
  include SupportHelper

  before do
    assigns[:issues] = [create_issue]
  end

  def do_render
    pending # url_for in lib/sortable.rb raises routing error
    # :controller => 'support', :action => 'index'
    # (ok, but :protocol => 'https' is suppressed, which causes failure)
    render '/support/index'
  end

  it 'should have a forums link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', forums_path
    end
  end

  it 'should have a "lost license code" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', 'https://secure.wincent.com/a/support/registration/'
    end
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
      # as noted elsewhere, url_for gives crazy results in view specs
      # must use protected issues_search_path method
      with_tag 'a[href=?]', template.send(:issues_search_path)
    end
  end

  it 'should have a "new issue" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', new_issue_path
    end
  end

  it 'should render the issues list partial' do
    template.should_receive :render, :partial => 'issues/issues'
    do_render
  end
end
