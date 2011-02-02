require File.expand_path('acceptance_helper', File.dirname(__FILE__))

feature 'snippets' do
  background do
    @snippet = Snippet.make! :body => "hello,\nworld\n"
  end

  scenario 'viewing a snippet in plain-text format' do
    visit snippet_path(@snippet, :format => 'txt')
    page.body.should == @snippet.body
    page.response_headers['Content-Type'].should =~ %r{\Atext/plain\b}
  end
end
