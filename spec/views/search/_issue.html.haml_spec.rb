require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_issue' do
  before do
    @issue          = create_issue
    @result_number  = 47
    template.stub!(:model).and_return(@issue)
    template.stub!(:result_number).and_return(@result_number)
  end

  def do_render
    render '/search/_issue'
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the issue summary as link text' do
    do_render
    response.should have_tag('a', @issue.summary)
  end

  it 'should link to the issue' do
    do_render
    response.should have_tag('a[href=?]', issue_path(@issue))
  end

  it 'should show the timeinfo for the issue' do
    template.should_receive(:timeinfo).with(@issue)
    do_render
  end

  it 'should get the issue description' do
    @issue.should_receive(:description).and_return('foo')
    do_render
  end

  it 'should truncate the issue description to 240 characters' do
    template.should_receive(:truncate).with(@issue.description, 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated issue description through the wikitext translator' do
    description = 'foo'
    description.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(description)
    do_render
  end

  it 'should use the preserve helper to make Haml mangle the excerpt a little bit less' do
    description = 'foo'
    description.stub!(:w).and_return('foo')
    template.stub!(:truncate).and_return(description)
    template.should_receive(:preserve).with(description)
    do_render
  end
end
