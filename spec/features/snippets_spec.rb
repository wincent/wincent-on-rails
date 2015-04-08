require 'spec_helper'

feature 'snippets' do
  background do
    @snippet = Snippet.make! :body => "hello,\nworld\n"
  end

  scenario 'viewing a snippet in plain-text format' do
    visit snippet_path(@snippet, :format => 'txt')
    expect(page.response_headers['Content-Type']).to match(%r{\Atext/plain\b})
    expect(page.source).to eq(@snippet.body)
  end
end
