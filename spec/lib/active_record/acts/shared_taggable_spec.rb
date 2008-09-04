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
    @object.instance_eval { @pending_tags }.should == 'hello world'

    # reading reads from the database
    @object.tag 'foo bar baz'
    @object.pending_tags.should == 'foo bar baz'
  end

  it 'should allow tagging at creation time' do
    # we explicitly test this because this is a "has many through" association and so isn't automatic
    @new_object.pending_tags = 'foo bar baz'
    @new_object.save!
    @new_object.tag_names.should == ['foo', 'bar', 'baz']
  end
end
