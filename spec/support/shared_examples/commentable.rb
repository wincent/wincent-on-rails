shared_examples_for 'commentable' do
  before do
    @comment1 = add_comment :awaiting_moderation => false, :public => false
    @comment2 = add_comment :awaiting_moderation => false, :public => true
    @comment3 = add_comment :awaiting_moderation => false, :public => true
    @comment4 = add_comment :awaiting_moderation => false, :public => false
    @comment5 = add_comment :awaiting_moderation => true,  :public => true
    @comment6 = add_comment :awaiting_moderation => true,  :public => false
  end

  def add_comment overrides = {}
    comment = commentable.comments.build :body => Sham.random
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    commentable.reload
    comment
  end

  it 'finds comments in ascending (chronological) order by creation date' do
    commentable.comments.each do |comment|
      Comment.update_all ['created_at = ?', comment.id.days.ago], ['id = ?', comment.id]
    end
    commentable.reload.comments.should =~ commentable.comments
  end

  it 'finds all published comments' do
    commentable.comments.published.to_a.should =~ [@comment2, @comment3]
  end

  it 'finds all unmoderated comments' do
    # "unmoderated" means :awaiting_moderation => true
    commentable.comments.unmoderated.to_a.should =~ [@comment5, @comment6]
  end

  it 'updates the comments_count cache when a comment is added and not held for moderation (ie. admin comments)' do
    expect do
      add_comment :awaiting_moderation => false
    end.to change { commentable.comments_count }.by(1)
  end

  it 'does not update the comments_count cache when a comment is added and held for moderation' do
    expect do
      add_comment :awaiting_moderation => true
    end.to_not change { commentable.comments_count }
  end

  it 'updates the comments_count cache when a comment is added and moderated as ham' do
    expect do
      add_comment :awaiting_moderation => true
    end.to_not change { commentable.comments_count }

    expect do
      Comment.last.moderate_as_ham!
      commentable.reload
    end.to change { commentable.comments_count }.by(1)
  end

  it 'updates the comments_count cache when a ham comment is later destroyed' do
    expect do
      add_comment :awaiting_moderation => true
    end.to_not change { commentable.comments_count }

    expect do
      Comment.last.moderate_as_ham!
      commentable.reload
    end.to change { commentable.comments_count }.by(1)

    expect do
      Comment.last.destroy
      commentable.reload
    end.to change { commentable.comments_count }.by(-1)
  end

  # TODO: also check that last_commenter field is correctly updated
end

# ie. issues, forum topics
shared_examples_for 'commentable (updating timestamps for comment changes)' do
  def add_comment overrides = {}
    comment = commentable.comments.build :body => Sham.random
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    commentable.reload
    comment
  end

  # BUG: topic and issue work differently, can't use the same spec for both
  # this is probably codesmell, the fact that I have to write different tests
  # once again i'm thinking about whether topic should have no "body" element and just a "comment" object attached from the start
  #it 'has a nil timestamp when there are no comments' do
  #  commentable.comments.should be_empty
  #  commentable.last_commented_at.to_s.should == commentable.updated_at.to_s
  #end

  it 'uses the comment timestamp when a comment is added and is not held for moderation (ie. admin comments)' do
    commentable.comments.should be_empty
    comment = add_comment :awaiting_moderation => false
    commentable.updated_at.to_s.should == comment.updated_at.to_s
  end

  it 'does not update the timestamp when a comment is added and held for moderation' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    add_comment :awaiting_moderation => true
    commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'updates the timestamp when a comment is added and is moderated as ham' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    commentable.reload
    commentable.updated_at.to_s.should == comment.updated_at.to_s
  end

  it 'amends the timestamp when a ham comment is later destroyed' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    commentable.reload
    commentable.updated_at.to_s.should == comment.updated_at.to_s
    comment.destroy
    commentable.reload
    commentable.updated_at.to_s.should == start_date.to_s
  end
end

# ie. blog posts, wiki articles
shared_examples_for 'commentable (not updating timestamps for comment changes)' do
  def add_comment overrides = {}
    comment = commentable.comments.build :body => Sham.random
    overrides.each { |k,v| comment.send("#{k.to_s}=", v) }
    comment.save
    commentable.reload
    comment
  end

  # BUG: see corresponding comment above about different behaviour in Issues and Topics
  #it 'has a nil timestamp when there are no comments'

  it 'uses the commentable updated timestamp when a comment is added and is not held for moderation (ie. admin comments)' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    comment = add_comment :awaiting_moderation => false
    commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'uses the commentable updated timestamp when a comment is added and held for moderation' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    add_comment :awaiting_moderation => true
    commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'uses the commentable updated timestamp when a comment is added and is moderated as ham' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    commentable.reload
    commentable.updated_at.to_s.should == start_date.to_s
  end

  it 'uses the commentable updated timestamp when a ham comment is later destroyed' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    comment = add_comment :awaiting_moderation => true
    commentable.updated_at.to_s.should == start_date.to_s
    comment.moderate_as_ham!
    commentable.reload
    commentable.updated_at.to_s.should == start_date.to_s
    comment.destroy
    commentable.reload
    commentable.updated_at.to_s.should == start_date.to_s
  end
end
