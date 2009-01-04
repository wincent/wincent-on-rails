require File.dirname(__FILE__) + '/../spec_helper'

# this is the first time I've ever written helper specs,
# so I am not sure if I am going too far typing the specs
# to the internal implementation details of the methods

describe ArticlesHelper do
end

describe ArticlesHelper, 'body_html method (removed with Rails 2.2.0)' do
  include ArticlesHelper

  # the body_html method is no longer needed as of Rail 2.2.0 due to a behaviour change
  # but we retain a specs here to catch any further behaviour changes in the future
  it 'should use the empty string as an article body on new records' do
    Article.new.body.should == ''
  end
end

describe ArticlesHelper, 'link_to_update_preview method' do
  include ArticlesHelper

  it 'should call link_to_remote' do
    should_receive(:link_to_remote)
    link_to_update_preview
  end

  it 'should use "update" as the link text' do
    should_receive(:link_to_remote).with('update', anything(), anything())
    link_to_update_preview
  end

  it 'should pass the common options to link_to_remote' do
    should_receive(:link_to_remote).with(anything(), common_options, anything())
    link_to_update_preview
  end

  it 'should pass a class of "update_link" to link_to_remote' do
    should_receive(:link_to_remote).with(anything(), anything(), :class => 'update_link')
    link_to_update_preview
  end
end

describe ArticlesHelper, 'observe_body' do
  include ArticlesHelper

  it 'should call observe_field' do
    should_receive(:observe_field)
    observe_body
  end

  it 'should observe the "article_body" ID' do
    should_receive(:observe_field).with('article_body', anything())
    observe_body
  end

  it 'should pass the common options to observe_field, merging in a frequency option of 30' do
    @options = mock 'options'
    should_receive(:common_options).and_return(@options)
    @options.should_receive(:merge).with(:frequency => 30.0).and_return(@options)
    should_receive(:observe_field).with(anything(), @options)
    observe_body
  end
end

describe ArticlesHelper, 'common options' do
  include ArticlesHelper

  it 'should use the wiki index path as the URL' do
    common_options[:url].should == articles_path
  end

  it 'should update via POST (to allow large updates)' do
    common_options[:method].should == 'post'
  end

  it 'should update the preview ID' do
    common_options[:update].should == 'preview'
  end

  it 'should pass the body parameter' do
    common_options[:with].should =~ /\A'body='/
  end

  it 'should URI-escape the parameter' do
    common_options[:with].should =~ /encodeURIComponent/
  end

  it 'should pass the contents of the article body' do
    common_options[:with].should =~ /\$\('article_body'\).value/
  end

  it 'should show the spinner before' do
    common_options[:before].should == "Element.show('spinner')"
  end

  it 'should hide the spinner on completion' do
    common_options[:complete].should == "Element.hide('spinner')"
  end
end
