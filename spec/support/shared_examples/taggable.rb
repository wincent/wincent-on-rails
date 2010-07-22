shared_examples_for 'taggable' do
  it 'responds to the tag message' do
    model.tag 'foo'
    model.tag_names.should == ['foo']
  end

  it 'responds to the untag message' do
    model.tag 'foo'
    model.untag 'foo'
    model.tag_names.should == []
  end

  it 'responds to the tag_names message' do
    model.tag_names.should == []
  end

  it 'has a pending_tags virtual attribute' do
    # writing stores to the instance variable
    model.pending_tags = 'hello world'
    model.instance_variable_get('@pending_tags').should == 'hello world'

    # reading reads from the instance variable
    model.pending_tags.should == 'hello world'

    # but after saving, reading reads from the database
    model.save
    model.tag 'foo bar baz'
    model.pending_tags.should == 'hello world foo bar baz'
  end

  it 'allows tagging at creation time' do
    # we explicitly test this because this is a "has many through" association and so isn't automatic
    new_model.pending_tags = 'foo bar baz'
    new_model.save!
    new_model.tag_names.should == ['foo', 'bar', 'baz']
  end

  it 'persists tags across saves' do
    # was a bug; see: http://rails.wincent.com/issues/1197
    model.tag 'foo'
    model.save
    model.tag_names.should == ['foo']
  end

  it 'validates pending tags' do
    model.pending_tags = 'foo bar baz.baz foo3'
    model.should_not fail_validation_for(:pending_tags)
  end

  # was a bug (passed but shouldn't have)
  it 'fails validation for incorrect pending tags' do
    model.pending_tags = 'foo_bar'
    model.should fail_validation_for(:pending_tags)
  end

  # was a bug (or rather, accidentally passed only due to a bug)
  it 'is valid with blank pending tags' do
    model.pending_tags = ''
    model.should_not fail_validation_for(:pending_tags)
  end
end
