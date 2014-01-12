module SharedCommentableExampleHelpers
  def add_comment overrides = {}
    @comment = commentable.comments.new :body => Sham.random
    overrides.each { |k,v| @comment.send("#{k.to_s}=", v) }
    @comment.save
    commentable.reload
    @comment
  end
end

shared_examples_for 'commentable' do
  include SharedCommentableExampleHelpers

  it 'finds comments in ascending (chronological) order by creation date' do
    # add comments in now, future, past order just to make sure that
    # our results really are coming back in chronological order and not
    # just insertion order
    Timecop.travel(0) { @now = add_comment }
    Timecop.travel(10) { @future = add_comment }
    Timecop.travel(-20) { @past = add_comment }
    commentable.comments.should == [@past, @now, @future]
  end

  describe '#published' do
    it 'finds all published comments' do
      published = add_comment :awaiting_moderation => false, :public => true
      commentable.comments.published.to_a.should =~ [published]
    end

    it 'does not find unmoderated comments' do
      add_comment :awaiting_moderation => true,  :public => true
      add_comment :awaiting_moderation => true,  :public => false
      commentable.comments.published.to_a.should == []
    end

    it 'does not find private comments' do
      add_comment :awaiting_moderation => false, :public => false
      commentable.comments.published.to_a.should == []
    end
  end

  describe '#unmoderated' do
    it 'finds all unmoderated comments' do
      # "unmoderated" means :awaiting_moderation => true
      unmoderated_public   = add_comment :awaiting_moderation => true,  :public => true
      unmoderated_private  = add_comment :awaiting_moderation => true,  :public => false
      commentable.comments.unmoderated.to_a.should =~ [unmoderated_public, unmoderated_private]
    end

    it 'does not find published comments' do
      add_comment :awaiting_moderation => false, :public => true
      commentable.comments.unmoderated.to_a.should == []
    end

    it 'does not find private comments' do
      add_comment :awaiting_moderation => false, :public => false
      commentable.comments.unmoderated.to_a.should == []
    end
  end

  describe 'comments_count' do
    context 'a comment is added and not held for moderation (ie. an admin comment)' do
      it 'updates the counter cache' do
        expect do
          add_comment :awaiting_moderation => false
        end.to change { commentable.comments_count }.by(1)
      end
    end

    context 'a comment is added and held for moderation' do
      it 'does not update the counter cache' do
        expect do
          add_comment :awaiting_moderation => true
        end.to_not change { commentable.comments_count }
      end
    end

    context 'a comment is moderated as ham' do
      it 'updates the counter cache' do
        expect do
          add_comment :awaiting_moderation => true
        end.to_not change { commentable.comments_count }

        expect do
          @comment.moderate_as_ham!
          commentable.reload
        end.to change { commentable.comments_count }.by(1)
      end
    end

    context 'a ham comment is later destroyed' do
      it 'updates the counter cache' do
        expect do
          add_comment :awaiting_moderation => true
        end.to_not change { commentable.comments_count }

        expect do
          @comment.moderate_as_ham!
          commentable.reload
        end.to change { commentable.comments_count }.by(1)

        expect do
          @comment.destroy
          commentable.reload
        end.to change { commentable.comments_count }.by(-1)
      end
    end
  end

  # TODO: also check that last_commenter field is correctly updated
end

# ie. issues, forum topics
shared_examples_for 'commentable (updating timestamps for comment changes)' do
  include SharedCommentableExampleHelpers

  # BUG: topic and issue work differently, can't use the same spec for both
  # this is probably codesmell, the fact that I have to write different tests
  # once again i'm thinking about whether topic should have no "body" element and just a "comment" object attached from the start
  #it 'has a nil timestamp when there are no comments' do
  #  commentable.comments.should be_empty
  #  commentable.last_commented_at.to_s.should == commentable.updated_at.to_s
  #end

  context 'a comment is added and not held for moderation (ie. an admin comment)' do
    it 'uses the comment timestamp to update the commentable timestamp' do
      commentable.comments.should be_empty
      add_comment :awaiting_moderation => false
      commentable.updated_at.should be_within(1).of(@comment.updated_at)
    end
  end

  context 'a comment is added and held for moderation' do
    it 'uses the commentable timestamp, irrespective of the timestamp(s) on the comment' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      add_comment :awaiting_moderation => true
      commentable.updated_at.should be_within(1).of(start_date)
    end
  end

  context 'a comment is moderated as ham' do
    it 'uses the comment timestamp to update the commentable timestamp' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      Timecop.travel(10) { add_comment :awaiting_moderation => true }
      commentable.updated_at.should be_within(1).of(start_date)
      @comment.moderate_as_ham!
      commentable.reload.updated_at.should be_within(1).of(@comment.updated_at)
    end
  end

  context 'a ham comment is later destroyed' do
    it 'uses the comment timestamp to update the commentable timestamp' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      Timecop.travel(10) { add_comment :awaiting_moderation => true }
      commentable.updated_at.should be_within(1).of(start_date)
      @comment.moderate_as_ham!
      commentable.reload.updated_at.should be_within(1).of(@comment.updated_at)
      @comment.destroy
      commentable.reload.updated_at.should be_within(1).of(start_date)
    end
  end
end

# ie. blog posts, snippets, wiki articles
shared_examples_for 'commentable (not updating timestamps for comment changes)' do
  include SharedCommentableExampleHelpers

  # BUG: see corresponding comment above about different behaviour in Issues and Topics
  #it 'has a nil timestamp when there are no comments'

  context 'a comment is added and not helf for moderation (ie. an admin comment)' do
    it 'uses the commentable timestamp, irrespective of the timestamp(s) on the comment' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      Timecop.travel(10) { add_comment :awaiting_moderation => false }
      commentable.updated_at.should be_within(1).of(start_date)
    end
  end

  context 'a comment is added and held for moderation' do
    it 'uses the commentable timestamp, irrespective of the timestamp(s) on the comment' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      Timecop.travel(10) { add_comment :awaiting_moderation => true }
      commentable.updated_at.should be_within(1).of(start_date)
    end
  end

  context 'a comment is moderated as ham' do
    it 'uses the commentable timestamp, irrespective of the timestamp(s) on the comment' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      Timecop.travel(10) { add_comment :awaiting_moderation => true }
      commentable.updated_at.should be_within(1).of(start_date)
      @comment.moderate_as_ham!
      commentable.reload.updated_at.should be_within(1).of(start_date)
    end
  end

  context 'a ham comment is later destroyed' do
    it 'uses the commentable timestamp, irrespective of the timestamp(s) on the comment' do
      commentable.comments.should be_empty
      start_date = commentable.updated_at
      Timecop.travel(10) { add_comment :awaiting_moderation => true }
      commentable.updated_at.should be_within(1).of(start_date)
      @comment.moderate_as_ham!
      commentable.reload.updated_at.should be_within(1).of(start_date)
      @comment.destroy
      commentable.reload.updated_at.should be_within(1).of(start_date)
    end
  end
end
