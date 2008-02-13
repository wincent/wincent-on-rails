require File.dirname(__FILE__) + '/../spec_helper'

# this is the first time I've ever written helper specs,
# so I am not sure if I am going too far typing the specs
# to the internal implementation details of the methods

describe ArticlesHelper do
  it 'should include the ArticleHelper' do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(ArticlesHelper)
  end
end

describe ArticlesHelper, 'body_html method' do
  it 'should return the empty string if @article is nil' do
    @article = nil
    body_html.should == ''
  end

  it 'should get the article body, convert to wikitext, and preserve whitespace' do
    # the number of chained calls here makes it hard to split these expectations out into multiple examples
    @article  = mock_model(Article)
    @body     = String.random
    @wikitext = @body.w
    @article.should_receive(:body).and_return(@body)
    @body.should_receive(:w).and_return(@wikitext)
    should_receive(:preserve).and_return('foobar')
    body_html.should == 'foobar'
  end
end

describe ArticlesHelper, 'link_to_update_preview method' do
  it 'should call link_to_remote' do
    should_receive(:link_to_remote)
    link_to_update_preview
  end

  it 'should use "update" as the link text' do
    should_receive(:link_to_remote).with('update', anything())
    link_to_update_preview
  end

  it 'should pass the common options to link_to_remote' do
    should_receive(:link_to_remote).with(anything(), common_options)
    link_to_update_preview
  end
end

describe ArticlesHelper, 'observe_body' do
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
  it 'should use the wiki index path as the URL' do
    common_options[:url].should == wiki_index_path
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
