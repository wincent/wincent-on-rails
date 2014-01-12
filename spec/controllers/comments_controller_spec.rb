require 'spec_helper'

describe CommentsController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#edit' do
    context 'logged in as admin' do
      before do
        @comment = Comment.make!
        log_in_as_admin
      end

      def do_get
        get :edit, id: @comment.id
      end

      it 'runs the "require_admin" before filter' do
        mock(controller).require_admin
        do_get
      end

      it 'finds the comment' do
        mock(Comment).find(@comment.id.to_s)
        do_get
      end

      it 'is successful' do
        do_get
        response.should be_success
      end

      it 'renders the edit template' do
        do_get
        response.should render_template('edit')
      end
    end

    context 'logged in as normal user' do
      before do
        @comment = Comment.make!
      end

      # strictly speaking this is re-testing the require_admin method
      # but the effort is minimal, so it doesn't hurt to err on the safe side
      it 'denies access to the "edit" action' do
        log_in
        get :edit, id: @comment.id
        response.should redirect_to(login_path)
        flash[:notice].should =~ /requires administrator privileges/
      end
    end

    context 'as an anonymous visitor' do
      before do
        @comment = Comment.make!
      end

      # strictly speaking this is re-testing the require_admin method
      # but the effort is minimal, so it doesn't hurt to err on the safe side
      it 'denies access to the "edit" action' do
        get :edit, id: @comment.id
        response.should redirect_to(login_path)
        flash[:notice].should =~ /requires administrator privileges/
      end
    end
  end

  describe '#update' do
    context 'logged in as admin' do
      before do
        @article = Article.make!
        @comment = Comment.make! commentable: @article
        log_in_as_admin
      end

      def do_put
        put :update,
          article_id: @article.id,
          id:         @comment.id,
          comment:    { body: 'foo' }
      end

      it 'runs the "require_admin" before filter' do
        mock(controller).require_admin
        do_put
      end

      it 'finds the comment and assign it to an instance variable' do
        do_put
        assigns[:comment].should == @comment
      end

      it 'updates the comment' do
        mock(@comment).update_attributes('body' => 'foo')
        stub(Comment).find() { @comment }
        do_put
      end

      it 'shows a notice on success' do
        stub(@comment).save { true }
        stub(Comment).find() { @comment }
        do_put
        flash[:notice].should =~ /Successfully updated/
      end

      it 'redirects to the comment path on success for comments not awaiting moderation' do
        stub(@comment).save { true }
        stub(Comment).find() { @comment }
        do_put
        response.should redirect_to(controller.send(:nested_comment_path, @comment))
      end

      it 'redirects to the list of comments awaiting moderation on success for comments that are awaiting moderation' do
        @comment.awaiting_moderation = true
        stub(@comment).save { true }
        stub(Comment).find() { @comment }
        do_put
        response.should redirect_to(comments_path)
      end

      it 'shows an error on failure' do
        stub(@comment).save { false }
        stub(Comment).find() { @comment }
        do_put
        flash[:error].should =~ /Update failed/
      end

      it 'renders the edit template again on failure' do
        stub(@comment).save { false }
        stub(Comment).find() { @comment }
        do_put
        response.should render_template('edit')
      end
    end
  end

  # Testing the CommentsController (use of ActionController::ForbiddenError) and
  # AppController (use of "forbidden" method) here, but using the
  # SnippetsController as a concrete example.
  describe '#new' do
    describe 'when commenting not allowed' do
      before do
        snippet = Snippet.make! accepts_comments: false
        get :new, snippet_id: snippet.id
      end

      it 'is not successful' do
        response.should_not be_success
      end

      it 'returns a 403 status' do
        response.status.should == 403
      end
    end
  end
end
