require File.dirname(__FILE__) + '/../../spec_helper'

describe '/support/index' do
  include SupportHelper

  before do
    assigns[:issues] = [create_issue]
  end

  def do_render
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
      with_tag 'a[href=?]', template.url_for(:controller => 'search', :action => 'issues')
    end
  end

  it 'should have a "new issue" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', new_issue_path
    end
  end

  it 'should render the issues list partial' do
    template.expect_render :partial => 'issues/issues'
    do_render
  end
end
