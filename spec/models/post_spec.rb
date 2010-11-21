require 'spec_helper'

describe Post, 'creation' do
  before do
    @post = Post.make!
  end

  it 'should default to being public' do
    @post.public.should == true
  end

  it 'should default to accepting comments' do
    @post.accepts_comments.should == true
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    length = 128 * 1024
    long_body = 'x' * length
    post = Post.make! :body => long_body
    post.body.length.should == length
    post.reload
    post.body.length.should == length
  end
end

describe Post, 'comments association' do
  it 'should respond to the comments message' do
    Post.make!.comments.should == []
  end
end

# :title, :permalink, :excerpt, :body, :public, :accepts_comments, :pending_tags
describe Post, 'accessible attributes' do
  it 'should allow mass-assignment to the title' do
    Post.make.should allow_mass_assignment_of(:title => Sham.random)
  end

  it 'should allow mass-assignment to the permalink' do
    Post.make.should allow_mass_assignment_of(:permalink => Sham.random)
  end

  it 'should allow mass-assignment to the excerpt' do
    Post.make.should allow_mass_assignment_of(:excerpt => Sham.random)
  end

  it 'should allow mass-assignment to the body' do
    Post.make.should allow_mass_assignment_of(:body => Sham.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    Post.make(:public => false).should allow_mass_assignment_of(:public => true)
  end

  it 'should allow mass-assignment to the "accepts comments" attribute' do
    Post.make(:accepts_comments => false).should allow_mass_assignment_of(:accepts_comments => true)
  end

  it 'should allow mass-assignment to the "pending tags" attribute' do
    Post.make.should allow_mass_assignment_of(:pending_tags => 'foo bar baz')
  end
end

describe Post, 'validating the title' do
  it 'should require it to be present' do
     Post.make(:title => nil).should fail_validation_for(:title)
  end

  it 'should not require it to be unique' do
    title = Sham.random
    Post.make!(:title => title).should be_valid
    Post.make(:title => title).should_not fail_validation_for(:title)
  end
end

describe Post, 'validating the permalink' do
  it 'should require it to be unique' do
    permalink = Sham.random.downcase
    Post.make!(:permalink => permalink).should be_valid
    Post.make(:permalink => permalink).should fail_validation_for(:permalink)
  end

  it 'should allow letters, numbers, hyphens and periods' do
    Post.make(:permalink => 'foo-bar-baz-10').should_not fail_validation_for(:permalink)
  end

  it 'should disallow spaces' do
    Post.make(:permalink => 'a b c').should fail_validation_for(:permalink)
  end

  it 'should disallow non-ASCII characters' do
    Post.make(:permalink => 'formación').should fail_validation_for(:permalink)
  end
end

describe Post, 'validating the excerpt' do
  it 'should require it to be present' do
    Post.make(:excerpt => nil).should fail_validation_for(:excerpt)
  end
end

describe Post, 'validating the body' do
  it 'should consider it optional' do
    Post.make(:body => nil).should_not fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    Post.make(:body => long_body).should fail_validation_for(:body)
  end
end

describe Post, 'autogeneration of permalink' do
  it 'should generate it based on title if not present' do
    title = Sham.random
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == title.downcase
  end

  it 'should downcase' do
    title = 'FooBar'
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'foobar'
  end

  it 'should convert spaces into hyphens' do
    title = 'hello world'
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'hello-world'
  end

  it 'should convert runs of spaces into a single hyphen' do
    title = 'hello        there       world'
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'hello-there-world'
  end

  it 'should allow numbers' do
    title = 'area 51'
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'area-51'
  end

  it 'should allow periods' do
    title = 'upgrading to 10.5.2'
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'upgrading-to-10.5.2'
  end

  it 'should convert runs of non-ASCII characters into hyphens' do
    title = 'cañon información más €'
    post = Post.make(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'ca-on-informaci-n-m-s'
  end

  it 'handles the pathological case where the title reduces to a zero length string (saved record)' do
    post = Post.make!(:title => 'áéíóú')
    post.permalink = nil
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == post.id.to_s
  end

  it 'handles the pathological case where the title reduces to a zero length string (new record)' do
    post = Post.make(:title => 'áéíóú', :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'post' # we don't even have an id yet
  end

  it 'should generate unique permalinks' do
    permalink = Sham.random.downcase
    Post.make!(:permalink => permalink)
    post = Post.make!(:title => permalink, :permalink => nil)
    post.permalink.should == "#{permalink}-2"
    post = Post.make!(:title => permalink, :permalink => nil)
    post.permalink.should == "#{permalink}-3"
    post = Post.make!(:title => permalink, :permalink => nil)
    post.permalink.should == "#{permalink}-4"
  end

  it 'should use a non-greedy match when looking for duplicate permalinks' do
    # in other words, given proposed permalink "foo" and existing links "foo-bar", "foo-bar-2" and "foo-bar-3"
    # it should accept "foo" rather than proposing "foo-4" or "foo-bar-4"
    Post.make!(:permalink => 'foo-bar')
    Post.make!(:permalink => 'foo-bar-2')
    Post.make!(:permalink => 'foo-bar-3')
    post = Post.make!(:title => 'foo', :permalink => nil)
    post.permalink.should == 'foo'
  end
end

describe Post do
  it_has_behavior 'commentable' do
    let(:commentable) { Post.make! }
  end

  it_has_behavior 'commentable (not updating timestamps for comment changes)' do
    let(:commentable) { Post.make! }
  end

  it_has_behavior 'taggable' do
    let(:model) { Post.make! }
    let(:new_model) { Post.make }
  end

  describe '#title' do
    it 'defaults to nil' do
      Post.new.title.should be_nil
    end
  end

  describe '#permalink' do
    it 'defaults to nil' do
      Post.new.permalink.should be_nil
    end
  end

  describe '#excerpt' do
    it 'defaults to nil' do
      Post.new.excerpt.should be_nil
    end
  end

  describe '#body' do
    it 'defaults to nil' do
      Post.new.body.should be_nil
    end
  end

  describe '#public' do
    it 'defaults to true' do
      Post.new.public.should be_true
    end
  end

  describe '#accepts_comments' do
    it 'defaults to true' do
      Post.new.accepts_comments.should be_true
    end
  end

  describe '#comments_count' do
    it 'defaults to 0' do
      Post.new.comments_count.should be_zero
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Post.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Post.new.updated_at.should be_nil
    end
  end

  describe '#last_commenter_id' do
    it 'defaults to nil' do
      Post.new.last_commenter_id.should be_nil
    end
  end

  describe '#last_comment_id' do
    it 'defaults to nil' do
      Post.new.last_comment_id.should be_nil
    end
  end

  describe '#last_commented_at' do
    it 'defaults to nil' do
      Post.new.last_commented_at.should be_nil
    end
  end

  describe '#to_param' do
    context 'new record' do
      context 'no permalink set' do
        it 'returns nil' do
          Post.new.to_param.should == nil
        end
      end

      context 'permalink set' do
        it 'returns the permalink' do
          permalink = Sham.random.downcase
          Post.new(:permalink => permalink).to_param.should == permalink
        end
      end
    end

    context 'dirty record' do
      it 'uses the old (stored on database) permalink as param' do
        post = Post.make! :permalink => 'foo'
        post.permalink = 'bar'
        post.to_param.should == 'foo'
      end
    end
  end
end
