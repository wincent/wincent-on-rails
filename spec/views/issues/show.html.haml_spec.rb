require 'spec_helper'

describe 'issues/show' do
  before do
    @issue    = Issue.make!
    @comments = []
    @comment  = @issue.comments.new
  end

  it 'should show breadcrumbs' do
    render
    rendered.should have_css('div#breadcrumbs', :content => "#{@issue.kind_string.humanize} \##{@issue.id}")
  end

  it 'should advertise an atom feed' do
    mock(view).atom_link(@issue)
    render
  end

  context 'private issue' do
    before do
      @issue    = Issue.make!(:public => false)
      @comments = []
      @comment  = @issue.comments.new
    end

    it 'should not advertise an atom feed' do
      do_not_allow(view).atom_link.with_any_args
      render
    end
  end

  context 'viewed by an administrator' do
    before do
      @issue    = Issue.make!
      @comments = []
      @comment  = @issue.comments.new
      stub(view).admin? { true }
      render
    end

    it 'should show an edit link' do
      rendered.should have_css('a', :href => edit_issue_path(@issue))
    end

    it 'should show a destroy link' do
      rendered.should match(/destroy/) # not sure how best to test this, so this is a cheap stand-in for now
    end
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
      rendered.should_not have_css("a[href='#{edit_issue_path(@issue)}']")
    end

    it 'should not show a destroy link' do
      # not sure how best to test this, so this is a cheap stand-in for now
      rendered.should_not have_content('destroy')
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
      rendered.should have_content('Description none')
    end
  end
end
