require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'active_record/acts/taggable'

describe ActiveRecord::Acts::Taggable, :shared => true do
  it 'should respond to the tag message' do
    @object.tag 'foo'
    @object.tag_names.should == ['foo']
  end

  it 'should respond to the untag message' do
    @object.tag 'foo'
    @object.untag 'foo'
    @object.tag_names.should == []
  end

  it 'should respond to the tag_names message' do
    @object.tag_names.should == []
  end

  it 'should have a pending_tags virtual attribute' do
    # writing stores to the instance variable
    @object.pending_tags = 'hello world'
    @object.instance_variable_get('@pending_tags').should == 'hello world'

    # reading reads from the instance variable
    @object.pending_tags.should == 'hello world'

    # but after saving, reading reads from the database
    @object.save
    @object.tag 'foo bar baz'
    @object.pending_tags.should == 'hello world foo bar baz'
  end

  it 'should allow tagging at creation time' do
    # we explicitly test this because this is a "has many through" association and so isn't automatic
    @new_object.pending_tags = 'foo bar baz'
    @new_object.save!
    @new_object.tag_names.should == ['foo', 'bar', 'baz']
  end

  it 'should persist tags across saves' do
    # was a bug; see: http://rails.wincent.com/issues/1197
    @object.tag 'foo'
    @object.save
    @object.tag_names.should == ['foo']
  end

  it 'should validate pending tags' do
    @object.pending_tags = 'foo bar baz.baz foo3'
    @object.should_not fail_validation_for(:pending_tags)
  end

  # was a bug (passed but shouldn't have)
  it 'should fail validation for incorrect pending tags' do
    @object.pending_tags = 'foo_bar'
    @object.should fail_validation_for(:pending_tags)
  end

  # was a bug (or rather, accidentally passed only due to a bug)
  it 'should be valid with blank pending tags' do
    @object.pending_tags = ''
    @object.should_not fail_validation_for(:pending_tags)
  end
end
