require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_issue' do
  before do
    @issue          = create_issue
    @result_number  = 47
  end

  def do_render
    render :partial => '/search/issue', :locals => { :model => @issue, :result_number => @result_number }
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the issue summary as link text' do
    do_render
    response.should have_tag('a', @issue.summary)
  end

  # was a bug
  it 'should escape HTML special characters in the issue summary' do
    @issue = create_issue :summary => '<em>foo</em>'
    do_render
    response.should_not have_text(%r{<em>foo</em>})
  end

  it 'should link to the issue' do
    do_render
    response.should have_tag('a[href=?]', issue_url(@issue))
  end

  it 'should show the timeinfo for the issue' do
    template.should_receive(:timeinfo).with(@issue)
    do_render
  end

  it 'should show the issue kind' do
    @issue.should_receive(:kind_string).and_return('le bug')
    do_render
    response.should have_text(/le bug/)
  end

  it 'should show the issue status' do
    @issue.should_receive(:status_string).and_return('cerrado')
    do_render
    response.should have_text(/cerrado/)
  end

  it 'should get the issue description' do
    # actually receives it twice (first time to check if blank)
    @issue.should_receive(:description).at_least(:once).and_return('foo')
    do_render
  end

  it 'should truncate the issue description to 240 characters' do
    template.should_receive(:truncate).with(@issue.description, :length => 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated issue description through the wikitext translator' do
    description = 'foo'
    description.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(description)
    do_render
  end
end
