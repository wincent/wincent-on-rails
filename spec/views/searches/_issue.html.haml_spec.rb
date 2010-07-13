require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'searches/_issue' do
  before do
    @issue          = Issue.make! :description => "can't print"
    @result_number  = 47
  end

  def do_render
    render :partial => 'searches/issue', :locals => { :model => @issue, :result_number => @result_number }
  end

  it 'shows the result number' do
    do_render
    rendered.should contain(/#{@result_number.to_s}/)
  end

  it 'uses the issue summary as link text' do
    do_render
    rendered.should have_selector('a', :content => @issue.summary)
  end

  # was a bug
  it 'escapes HTML special characters in the issue summary' do
    @issue = Issue.make! :summary => '<em>foo</em>'
    do_render
    rendered.should match('&lt;em&gt;foo&lt;/em&gt')
    rendered.should_not have_selector('em', :content => 'foo')
  end

  it 'links to the issue' do
    do_render
    rendered.should have_selector("a[href='#{issue_path @issue}']")
  end

  it 'shows the timeinfo for the issue' do
    mock(view).timeinfo(@issue)
    do_render
  end

  it 'shows the issue kind' do
    mock(@issue).kind_string { 'le bug' }
    do_render
    rendered.should contain(/le bug/)
  end

  it 'shows the issue status' do
    mock(@issue).status_string { 'cerrado' }
    do_render
    rendered.should contain(/cerrado/)
  end

  it 'gets the issue description' do
    do_render
    rendered.should contain("can't print")
  end

  it 'truncates the issue description to 240 characters' do
    mock(view).truncate(@issue.description, :length => 240, :safe => true)
    do_render
  end

  it 'passes the truncated issue description through the wikitext translator' do
    stub(view).truncate.with_any_args { mock('description').w(:base_heading_level => 2) }
    do_render
  end
end
