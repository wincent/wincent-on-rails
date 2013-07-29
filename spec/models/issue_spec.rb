require 'spec_helper'

describe Issue do
  before do
    @issue = Issue.make!
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support description content of over 128K' do
    # make sure the long description survives the round-trip from the db
    long_description = ('x' * 127 + ' ') * 1024
    issue = Issue.make! description: long_description
    issue.description.length.should == long_description.length
    issue.reload
    issue.description.length.should == long_description.length
  end

  let(:commentable) { Issue.make! }
  it_has_behavior 'commentable'
  it_has_behavior 'commentable (updating timestamps for comment changes)'

  it_has_behavior 'taggable' do
    let(:model) { Issue.make! }
    let(:new_model) { Issue.make }
  end

  describe '#kind' do
    it 'defaults to zero' do
      Issue.new.kind.should be_zero
    end
  end

  describe '#summary' do
    it 'defaults to nil' do
      Issue.new.summary.should be_nil
    end
  end

  describe '#public' do
    it 'defaults to true' do
      Issue.new.public.should be_true
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      Issue.new.user_id.should be_nil
    end
  end

  describe '#status' do
    it 'defaults to zero' do
      Issue.new.status.should be_zero
    end
  end

  describe '#description' do
    it 'defaults to nil' do
      Issue.new.description.should be_nil
    end
  end

  describe '#awaiting_moderation' do
    it 'defaults to true' do
      Issue.new.awaiting_moderation.should be_true
    end
  end

  describe '#comments_count' do
    it 'defaults to zero' do
      Issue.new.comments_count.should be_zero
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Issue.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Issue.new.updated_at.should be_nil
    end
  end

  describe '#last_commenter_id' do
    it 'defaults to nil' do
      Issue.new.last_commenter_id.should be_nil
    end
  end

  describe '#last_comment_id' do
    it 'defaults to nil' do
      Issue.new.last_comment_id.should be_nil
    end
  end

  describe '#last_commented_at' do
    it 'defaults to nil' do
      Issue.new.last_commented_at.should be_nil
    end
  end

  describe '#product_id' do
    it 'defaults to nil' do
      Issue.new.product_id.should be_nil
    end
  end

  describe '#accepts_comments' do
    it 'defaults to true' do
      Issue.new.accepts_comments.should be_true
    end
  end
end

describe Issue, 'creation' do
  it 'should default to accepting comments' do
    Issue.make.accepts_comments.should == true
  end
end

# :summary, :description, :public, :product_id, :kind
describe Issue, 'accessible attributes' do
  it 'should allow mass-assignment to the summary' do
    Issue.make.should allow_mass_assignment_of(summary: Sham.random)
  end

  it 'should allow mass-assignment to the description' do
    Issue.make.should allow_mass_assignment_of(description: Sham.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    Issue.make(public: false).should allow_mass_assignment_of(public: true)
  end

  it 'should allow mass-assignment to the product_id' do
    Issue.make.should allow_mass_assignment_of(product_id: Product.make!.id)
  end

  it 'should allow mass-assignment to the kind' do
    Issue.make.should allow_mass_assignment_of(kind: Issue::KIND[:feedback])
  end

  it 'should allow mass-assignment to the "status" attribute' do
    issue = Issue.make status: Issue::STATUS[:closed]
    issue.should allow_mass_assignment_of(status: Issue::STATUS[:open])
  end
end

describe Issue, 'validating the description' do
  it 'should not require it to be present' do
    Issue.make(description: '').should_not fail_validation_for(:description)
  end

  it 'should complain if longer than 128k' do
    long_description = 'x' * (128 * 1024 + 100)
    issue = Issue.make(description: long_description)
    issue.should fail_validation_for(:description)
  end
end
