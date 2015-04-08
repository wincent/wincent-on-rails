# encoding: utf-8
require 'spec_helper'

describe Post, 'creation' do
  before do
    @post = Post.make!
  end

  it 'should default to being public' do
    expect(@post.public).to eq(true)
  end

  it 'should default to accepting comments' do
    expect(@post.accepts_comments).to eq(true)
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    long_body = ('x' * 127 + ' ') * 1024
    post = Post.make! body: long_body
    expect(post.body.length).to eq(long_body.length)
    post.reload
    expect(post.body.length).to eq(long_body.length)
  end
end

describe Post, 'comments association' do
  it 'should respond to the comments message' do
    expect(Post.make!.comments).to eq([])
  end
end

# :title, :permalink, :excerpt, :body, :public, :accepts_comments, :pending_tags
describe Post, 'accessible attributes' do
  it 'should allow mass-assignment to the title' do
    expect(Post.make).to allow_mass_assignment_of(title: Sham.random)
  end

  it 'should allow mass-assignment to the permalink' do
    expect(Post.make).to allow_mass_assignment_of(permalink: Sham.random)
  end

  it 'should allow mass-assignment to the excerpt' do
    expect(Post.make).to allow_mass_assignment_of(excerpt: Sham.random)
  end

  it 'should allow mass-assignment to the body' do
    expect(Post.make).to allow_mass_assignment_of(body: Sham.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    expect(Post.make(public: false)).to allow_mass_assignment_of(public: true)
  end

  it 'should allow mass-assignment to the "accepts comments" attribute' do
    expect(Post.make(accepts_comments: false)).to allow_mass_assignment_of(accepts_comments: true)
  end

  it 'should allow mass-assignment to the "pending tags" attribute' do
    expect(Post.make).to allow_mass_assignment_of(pending_tags: 'foo bar baz')
  end
end

describe Post, 'validating the title' do
  it 'should require it to be present' do
     expect(Post.make(title: nil)).to fail_validation_for(:title)
  end

  it 'should not require it to be unique' do
    title = Sham.random
    expect(Post.make!(title: title)).to be_valid
    expect(Post.make(title: title)).not_to fail_validation_for(:title)
  end
end

describe Post, 'validating the permalink' do
  it 'should require it to be unique' do
    permalink = Sham.random.downcase
    expect(Post.make!(permalink: permalink)).to be_valid
    expect(Post.make(permalink: permalink)).to fail_validation_for(:permalink)
  end

  it 'should allow letters, numbers, hyphens and periods' do
    expect(Post.make(permalink: 'foo-bar-baz-10')).not_to fail_validation_for(:permalink)
  end

  it 'should disallow spaces' do
    expect(Post.make(permalink: 'a b c')).to fail_validation_for(:permalink)
  end

  it 'should disallow non-ASCII characters' do
    expect(Post.make(permalink: 'formación')).to fail_validation_for(:permalink)
  end
end

describe Post, 'validating the excerpt' do
  it 'should require it to be present' do
    expect(Post.make(excerpt: nil)).to fail_validation_for(:excerpt)
  end
end

describe Post, 'validating the body' do
  it 'should consider it optional' do
    expect(Post.make(body: nil)).not_to fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    expect(Post.make(body: long_body)).to fail_validation_for(:body)
  end
end

describe Post, 'autogeneration of permalink' do
  it 'should generate it based on title if not present' do
    title = Sham.random
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq(title.downcase)
  end

  it 'should downcase' do
    title = 'FooBar'
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('foobar')
  end

  it 'should convert spaces into hyphens' do
    title = 'hello world'
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('hello-world')
  end

  it 'should convert runs of spaces into a single hyphen' do
    title = 'hello        there       world'
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('hello-there-world')
  end

  it 'should allow numbers' do
    title = 'area 51'
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('area-51')
  end

  it 'should allow periods' do
    title = 'upgrading to 10.5.2'
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('upgrading-to-10.5.2')
  end

  it 'should convert runs of non-ASCII characters into hyphens' do
    title = 'cañon información más €'
    post = Post.make(title: title, permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('ca-on-informaci-n-m-s')
  end

  it 'handles the pathological case where the title reduces to a zero length string (saved record)' do
    post = Post.make!(title: 'áéíóú')
    post.permalink = nil
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq(post.id.to_s)
  end

  it 'handles the pathological case where the title reduces to a zero length string (new record)' do
    post = Post.make(title: 'áéíóú', permalink: nil)
    expect(post).not_to fail_validation_for(:permalink)
    expect(post.permalink).to eq('post') # we don't even have an id yet
  end

  it 'should generate unique permalinks' do
    permalink = Sham.random.downcase
    Post.make!(permalink: permalink)
    post = Post.make!(title: permalink, permalink: nil)
    expect(post.permalink).to eq("#{permalink}-2")
    post = Post.make!(title: permalink, permalink: nil)
    expect(post.permalink).to eq("#{permalink}-3")
    post = Post.make!(title: permalink, permalink: nil)
    expect(post.permalink).to eq("#{permalink}-4")
  end

  it 'should use a non-greedy match when looking for duplicate permalinks' do
    # in other words, given proposed permalink "foo" and existing links "foo-bar", "foo-bar-2" and "foo-bar-3"
    # it should accept "foo" rather than proposing "foo-4" or "foo-bar-4"
    Post.make!(permalink: 'foo-bar')
    Post.make!(permalink: 'foo-bar-2')
    Post.make!(permalink: 'foo-bar-3')
    post = Post.make!(title: 'foo', permalink: nil)
    expect(post.permalink).to eq('foo')
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
      expect(Post.new.title).to be_nil
    end
  end

  describe '#permalink' do
    it 'defaults to nil' do
      expect(Post.new.permalink).to be_nil
    end
  end

  describe '#excerpt' do
    it 'defaults to nil' do
      expect(Post.new.excerpt).to be_nil
    end
  end

  describe '#body' do
    it 'defaults to nil' do
      expect(Post.new.body).to be_nil
    end
  end

  describe '#public' do
    it 'defaults to true' do
      expect(Post.new.public).to eq(true)
    end
  end

  describe '#accepts_comments' do
    it 'defaults to true' do
      expect(Post.new.accepts_comments).to eq(true)
    end
  end

  describe '#comments_count' do
    it 'defaults to 0' do
      expect(Post.new.comments_count).to be_zero
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Post.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Post.new.updated_at).to be_nil
    end
  end

  describe '#last_commenter_id' do
    it 'defaults to nil' do
      expect(Post.new.last_commenter_id).to be_nil
    end
  end

  describe '#last_comment_id' do
    it 'defaults to nil' do
      expect(Post.new.last_comment_id).to be_nil
    end
  end

  describe '#last_commented_at' do
    it 'defaults to nil' do
      expect(Post.new.last_commented_at).to be_nil
    end
  end

  describe '#to_param' do
    context 'new record' do
      context 'no permalink set' do
        it 'returns nil' do
          expect(Post.new.to_param).to eq(nil)
        end
      end

      context 'permalink set' do
        it 'returns the permalink' do
          permalink = Sham.random.downcase
          expect(Post.new(permalink: permalink).to_param).to eq(permalink)
        end
      end
    end

    context 'dirty record' do
      it 'uses the old (stored on database) permalink as param' do
        post = Post.make! permalink: 'foo'
        post.permalink = 'bar'
        expect(post.to_param).to eq('foo')
      end
    end
  end
end
