require File.dirname(__FILE__) + '/../spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'active_record', 'acts', 'shared_taggable_spec')
require File.join(File.dirname(__FILE__), '..', 'lib', 'shared_commentable_spec')

describe Issue do
  before do
    @issue = create_issue
  end

  it 'should be valid' do
    @issue.should be_valid
  end
end

describe Issue, 'acting as commentable' do
  before do
    @commentable = create_issue
  end

  it_should_behave_like 'Commentable'
end

describe Issue, 'acting as taggable' do
  before do
    @object     = create_issue
    @new_object = new_issue
  end

  it_should_behave_like 'ActiveRecord::Acts::Taggable'
end
