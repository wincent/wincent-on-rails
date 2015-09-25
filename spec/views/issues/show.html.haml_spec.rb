require 'spec_helper'

describe 'issues/show' do
  before do
    @issue    = Issue.make!
    @comments = []
    @comment  = @issue.comments.new
  end

  it 'should show breadcrumbs' do
    render
    expect(rendered).to have_css('div#breadcrumbs',
                             text: "#{@issue.kind_string.humanize} \##{@issue.id}")
  end

  context 'viewed by a normal user' do
    before do
      @issue    = Issue.make!
      @comments = []
      @comment  = @issue.comments.new
      stub(view).admin? { false }
      render
    end

    it 'should not show an edit link' do
      expect(rendered).not_to have_css("a[href='#{edit_issue_path(@issue)}']")
    end

    it 'should not show a destroy link' do
      # not sure how best to test this, so this is a cheap stand-in for now
      expect(rendered).not_to have_content('destroy')
    end
  end

  context 'no description' do
    before do
      @issue    = Issue.make!(:description => '')
      @comments = []
      @comment  = @issue.comments.new
    end

    it 'should show "none"' do
      render
      expect(rendered).to have_content('Description none')
    end
  end
end
