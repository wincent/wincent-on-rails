require File.dirname(__FILE__) + '/../../../spec_helper'
require 'active_record/acts/taggable.rb'

# There are no plans to extact this into a separate plug-in, so piggy-back on the application's own test database.
def setup_db
  ActiveRecord::Schema.define do
    create_table :acts_as_taggable_test_models do |t|
      t.string :title
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.drop_table 'acts_as_taggable_test_models'
end

# Create a model purely for testing purposes so as to avoid dependening on a real model from the application.
class ActsAsTaggableTestModel < ActiveRecord::Base
  acts_as_taggable
end

describe ActiveRecord::Acts::Taggable, 'adding tag(s)' do
  before(:all) do
    setup_db
  end

  before do
    @model = ActsAsTaggableTestModel.create
  end

  it 'should do nothing if passed no parameters' do
    lambda { @model.tag }.should_not change { @model.tags.size }
  end

  it 'should add a single tag' do
    lambda { @model.tag 'foo' }.should change { @model.tags.size }.by(1)
  end

  it 'should add multiple, space-delimited tags' do
    lambda { @model.tag 'foo bar baz' }.should change { @model.tags.size }.by(3)
  end

  it 'should add multiple, comma-separated tags' do
    lambda { @model.tag 'foo, bar, baz' }.should change { @model.tags.size }.by(3)
  end

  it 'should ignore excess trailing or leading whitespace' do
    lambda { @model.tag '    foo   ,  bar  ,   baz  ' }.should change { @model.tags.size }.by(3)
  end

  it 'should add repeated items only once' do
    lambda { @model.tag 'foo foo foo' }.should change { @model.tags.size }.by(1)
  end

  it 'should have no effect for tags which have already been applied' do
    lambda { @model.tag 'foo' }.should change { @model.tags.size }.by(1)
    lambda { @model.tag 'foo' }.should change { @model.tags.size }.by(0)
  end

  it 'should accept an array as a parameter' do
    lambda { @model.tag ['foo', 'bar'] }.should change { @model.tags.size }.by(2)
  end

  it 'should handle nested arrays' do
    lambda { @model.tag ['foo', ['bar', 'baz, abc']] }.should change { @model.tags.size }.by(4)
  end

  after(:all) do
    ActsAsTaggableTestModel.destroy_all
    teardown_db
  end
end

describe ActiveRecord::Acts::Taggable, 'removing tag(s)' do
  before(:all) do
    setup_db
  end

  before do
    @model = ActsAsTaggableTestModel.create
  end

  it 'should do nothing if passed no parameters' do
    @model.tag 'foo bar baz'
    lambda { @model.untag }.should_not change { @model.tags.size }
  end

  it 'should remove a single tag' do
    @model.tag 'foo bar baz'
    lambda { @model.untag 'foo' }.should change { @model.tags.size }.by(-1)
  end

  it 'should remove multiple, space-delimited tags' do
    @model.tag 'foo bar baz'
    lambda { @model.untag 'foo bar' }.should change { @model.tags.size }.by(-2)
  end

  it 'should remove multiple, comma-separated tags' do
    @model.tag 'foo bar baz'
    lambda { @model.untag 'foo, bar' }.should change { @model.tags.size }.by(-2)
  end

  it 'should ignore excess trailing or leading whitespace' do
    @model.tag 'foo bar baz'
    lambda { @model.untag '    foo    ,    bar    ' }.should change { @model.tags.size }.by(-2)
  end

  it 'should handle repeated items' do
    @model.tag 'foo bar baz'
    lambda { @model.untag 'foo foo' }.should change { @model.tags.size }.by(-1)
  end

  it 'should have no effect for tags which have already been removed' do
    @model.tag 'foo bar baz'
    lambda { @model.untag 'foo' }.should change { @model.tags.size }.by(-1)
    lambda { @model.untag 'foo' }.should_not change { @model.tags.size }
  end

  it 'should have no effect for unknown tags' do
    @model.tag 'foo bar baz'
    lambda { @model.untag 'abc' }.should_not change { @model.tags.size }
  end

  it 'should accept an array as a parameter' do
    @model.tag 'foo bar baz'
    lambda { @model.untag ['foo', 'bar'] }.should change { @model.tags.size }.by(-2)
  end

  it 'should handle nested arrays' do
    @model.tag 'foo bar baz'
    lambda { @model.untag ['foo', ['bar']] }.should change { @model.tags.size }.by(-2)
  end

  after(:all) do
    ActsAsTaggableTestModel.destroy_all
    teardown_db
  end
end

describe ActiveRecord::Acts::Taggable, 'getting a list of tag name(s)' do
  before(:all) do
    setup_db
  end

  before do
    @model = ActsAsTaggableTestModel.create
  end

  it 'should return an empty array when there are no tags' do
    @model.tag_names.should == []
  end

  it 'should return an array of tag names when there are tags' do
    @model.tag 'foo bar baz'
    @model.tag_names.sort.should == ['bar', 'baz', 'foo']
  end

  after(:all) do
    ActsAsTaggableTestModel.destroy_all
    teardown_db
  end
end

