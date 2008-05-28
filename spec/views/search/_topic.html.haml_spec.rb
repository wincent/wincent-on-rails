require File.dirname(__FILE__) + '/../../spec_helper'

describe '/search/_topic' do
  before do
    @topic          = create_topic
    @result_number  = 47
  end

  def do_render
    render :partial => '/search/topic', :locals => { :model => @topic, :result_number => @result_number }
  end

  it 'should show the result number' do
    do_render
    response.should have_text(/#{@result_number.to_s}/)
  end

  it 'should use the topic title as link text' do
    do_render
    response.should have_tag('a', @topic.title)
  end

  it 'should link to the topic' do
    do_render
    response.should have_tag('a[href=?]', template.url_for(:controller => 'topics', :action => 'show', :id => @topic.id))
  end

  it 'should show the timeinfo for the topic' do
    template.should_receive(:timeinfo).with(@topic)
    do_render
  end

  it 'should get the topic body' do
    @topic.should_receive(:body).and_return('foo')
    do_render
  end

  it 'should truncate the topic body to 240 characters' do
    template.should_receive(:truncate).with(@topic.body, 240).and_return('foo')
    do_render
  end

  it 'should pass the truncated topic body through the wikitext translator' do
    body = 'foo'
    body.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(body)
    do_render
  end
end
