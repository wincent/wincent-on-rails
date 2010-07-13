require File.expand_path('../../spec_helper', File.dirname(__FILE__))

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

  # was a bug
  it 'should escape HTML special characters in the topic summary' do
    @topic = create_topic :title => '<em>foo</em>'
    do_render
    response.should_not have_text(%r{<em>foo</em>})
  end

  it 'should link to the topic' do
    do_render
    # must use protected topic_path method here because in the context of these specs url_for gives crazy results
    # (ie "/topics/show/815" instead of the correct "https://test.host/topics/815")
    response.should have_tag('a[href=?]', template.send(:topic_path, @topic))
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
    template.should_receive(:truncate).with(@topic.body, :length => 240, :safe => true).and_return('foo')
    do_render
  end

  it 'should pass the truncated topic body through the wikitext translator' do
    body = 'foo'
    body.should_receive(:w).and_return('foo')
    template.stub!(:truncate).and_return(body)
    do_render
  end
end
