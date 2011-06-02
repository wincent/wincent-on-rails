require 'spec_helper'

feature 'snippets' do
  background do
    @snippet = Snippet.make! :body => "hello,\nworld\n"
  end

  scenario 'viewing a snippet in plain-text format' do
    visit snippet_path(@snippet, :format => 'txt')
    page.response_headers['Content-Type'].should =~ %r{\Atext/plain\b}
    page.body.should == @snippet.body
  end
end
