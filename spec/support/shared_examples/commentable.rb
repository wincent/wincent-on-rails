shared_examples_for 'commentable' do
  before do
    add_comment :awaiting_moderation => false, :public => false
    add_comment :awaiting_moderation => false, :public => true
    add_comment :awaiting_moderation => false, :public => true
    add_comment :awaiting_moderation => false, :public => false
    add_comment :awaiting_moderation => true,  :public => true
    add_comment :awaiting_moderation => true,  :public => false
  end

  def add_comment overrides = {}
    @comments ||= []
    @comments << (@comment = commentable.comments.build :body => Sham.random)
    overrides.each { |k,v| @comment.send("#{k.to_s}=", v) }
    @comment.save
    commentable.reload
  end

  it 'finds comments in ascending (chronological) order by creation date' do
    commentable.comments.each do |comment|
      Comment.update_all ['created_at = ?', comment.id.days.ago], ['id = ?', comment.id]
    end
    commentable.reload.comments.should == commentable.comments
  end

  it 'finds all published comments' do
    commentable.comments.published.to_a.should =~ [@comments[1], @comments[2]]
  end

  it 'finds all unmoderated comments' do
    # "unmoderated" means :awaiting_moderation => true
    commentable.comments.unmoderated.to_a.should =~ [@comments[4], @comments[5]]
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
      @comment.moderate_as_ham!
      commentable.reload
    end.to change { commentable.comments_count }.by(1)
  end

  it 'updates the comments_count cache when a ham comment is later destroyed' do
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

  # TODO: also check that last_commenter field is correctly updated
end

# ie. issues, forum topics
shared_examples_for 'commentable (updating timestamps for comment changes)' do
  def add_comment overrides = {}
    @comment = commentable.comments.build :body => Sham.random
    overrides.each { |k,v| @comment.send("#{k.to_s}=", v) }
    @comment.save
    commentable.reload
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
    add_comment :awaiting_moderation => false
    commentable.updated_at.should be_within(1).of(@comment.updated_at)
  end

  it 'does not update the timestamp when a comment is added and held for moderation' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    add_comment :awaiting_moderation => true
    commentable.updated_at.should be_within(1).of(start_date)
  end

  it 'updates the timestamp when a comment is added and is moderated as ham' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    Timecop.travel(10) { add_comment :awaiting_moderation => true }
    commentable.updated_at.should be_within(1).of(start_date)
    @comment.moderate_as_ham!
    commentable.reload.updated_at.should be_within(1).of(@comment.updated_at)
  end

  it 'amends the timestamp when a ham comment is later destroyed' do
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

# ie. blog posts, tweets, snippets, wiki articles
shared_examples_for 'commentable (not updating timestamps for comment changes)' do
  def add_comment overrides = {}
    @comment = commentable.comments.build :body => Sham.random
    overrides.each { |k,v| @comment.send("#{k.to_s}=", v) }
    @comment.save
    commentable.reload
  end

  # BUG: see corresponding comment above about different behaviour in Issues and Topics
  #it 'has a nil timestamp when there are no comments'

  it 'uses the commentable updated timestamp when a comment is added and is not held for moderation (ie. admin comments)' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    Timecop.travel(10) { add_comment :awaiting_moderation => false }
    commentable.updated_at.should be_within(1).of(start_date)
  end

  it 'uses the commentable updated timestamp when a comment is added and held for moderation' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    Timecop.travel(10) { add_comment :awaiting_moderation => true }
    commentable.updated_at.should be_within(1).of(start_date)
  end

  it 'uses the commentable updated timestamp when a comment is added and is moderated as ham' do
    commentable.comments.should be_empty
    start_date = commentable.updated_at
    Timecop.travel(10) { add_comment :awaiting_moderation => true }
    commentable.updated_at.should be_within(1).of(start_date)
    @comment.moderate_as_ham!
    commentable.reload.updated_at.should be_within(1).of(start_date)
  end

  it 'uses the commentable updated timestamp when a ham comment is later destroyed' do
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
