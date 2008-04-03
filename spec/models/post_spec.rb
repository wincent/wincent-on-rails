require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'active_record', 'acts', 'shared_taggable_spec')
require File.join(File.dirname(__FILE__), '..', 'lib', 'shared_commentable_spec')

describe Post do
  it 'should be valid' do
    new_post.should be_valid
  end
end

describe Post, 'creation' do
  before do
    @post = create_post
  end

  it 'should default to being public' do
    @post.public.should == true
  end

  it 'should default to not accepting comments' do
    @post.accepts_comments.should == false
  end
end

describe Post, 'comments association' do
  it 'should respond to the comments message' do
    create_post.comments.should == []
  end
end

describe Post, 'acting as commentable' do
  before do
    @commentable = create_post
  end

  it_should_behave_like 'Commentable'
end

describe Post, 'acting as taggable' do
  before do
    @object     = create_post
    @new_object = new_post
  end

  it_should_behave_like 'ActiveRecord::Acts::Taggable'
end

# :title, :permalink, :excerpt, :body, :public, :accepts_comments, :pending_tags
describe Post, 'accessible attributes' do
  it 'should allow mass-assignment to the title' do
    new_post.should allow_mass_assignment_of(:title => String.random)
  end

  it 'should allow mass-assignment to the permalink' do
    new_post.should allow_mass_assignment_of(:permalink => String.random)
  end

  it 'should allow mass-assignment to the excerpt' do
    new_post.should allow_mass_assignment_of(:excerpt => String.random)
  end

  it 'should allow mass-assignment to the body' do
    new_post.should allow_mass_assignment_of(:body => String.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    new_post(:public => false).should allow_mass_assignment_of(:public => true)
  end

  it 'should allow mass-assignment to the "accepts comments" attribute' do
    new_post(:accepts_comments => false).should allow_mass_assignment_of(:accepts_comments => true)
  end

  it 'should allow mass-assignment to the "pending tags" attribute' do
    new_post.should allow_mass_assignment_of(:pending_tags => 'foo bar baz')
  end
end

describe Post, 'validating the title' do
  it 'should require it to be present' do
     new_post(:title => nil).should fail_validation_for(:title)
  end

  it 'should not require it to be unique' do
    title = String.random
    create_post(:title => title).should be_valid
    new_post(:title => title).should_not fail_validation_for(:title)
  end
end

describe Post, 'validating the permalink' do
  it 'should require it to be unique' do
    permalink = String.random.downcase
    create_post(:permalink => permalink).should be_valid
    new_post(:permalink => permalink).should fail_validation_for(:permalink)
  end

  it 'should allow letters, numbers, hyphens and periods' do
    new_post(:permalink => 'foo-bar-baz-10').should_not fail_validation_for(:permalink)
  end

  it 'should disallow spaces' do
    new_post(:permalink => 'a b c').should fail_validation_for(:permalink)
  end

  it 'should disallow non-ASCII characters' do
    new_post(:permalink => 'formación').should fail_validation_for(:permalink)
  end
end

describe Post, 'validating the excerpt' do
  it 'should require it to be present' do
    new_post(:excerpt => nil).should fail_validation_for(:excerpt)
  end
end

describe Post, 'autogeneration of permalink' do
  it 'should generate it based on title if not present' do
    title = String.random
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == title.downcase
  end

  it 'should downcase' do
    title = 'FooBar'
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'foobar'
  end

  it 'should convert spaces into hyphens' do
    title = 'hello world'
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'hello-world'
  end

  it 'should convert runs of spaces into a single hyphen' do
    title = 'hello        there       world'
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'hello-there-world'
  end

  it 'should allow numbers' do
    title = 'area 51'
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'area-51'
  end

  it 'should allow periods' do
    title = 'upgrading to 10.5.2'
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'upgrading-to-10.5.2'
  end

  it 'should convert runs of non-ASCII characters into hyphens' do
    title = 'cañon información más €'
    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'ca-on-informaci-n-m-s'
  end

  it 'should handle the pathological case where the title reduces to a zero length string' do
    title = 'áéíóú'
    post = create_post(:title => title)
    post.permalink = nil
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == post.id.to_s # note that we fall back to the post id here

    post = new_post(:title => title, :permalink => nil)
    post.should_not fail_validation_for(:permalink)
    post.permalink.should == 'post' # this case is even worse: we don't even have an id yet
  end

  it 'should generate unique permalinks' do
    permalink = String.random.downcase
    create_post(:permalink => permalink)
    post = create_post(:title => permalink, :permalink => nil)
    post.permalink.should == "#{permalink}-2"
    post = create_post(:title => permalink, :permalink => nil)
    post.permalink.should == "#{permalink}-3"
    post = create_post(:title => permalink, :permalink => nil)
    post.permalink.should == "#{permalink}-4"
  end

  it 'should use a non-greedy match when looking for duplicate permalinks' do
    # in other words, given proposed permalink "foo" and existing links "foo-bar", "foo-bar-2" and "foo-bar-3"
    # it should accept "foo" rather than proposing "foo-4" or "foo-bar-4"
    create_post(:permalink => 'foo-bar')
    create_post(:permalink => 'foo-bar-2')
    create_post(:permalink => 'foo-bar-3')
    post = create_post(:title => 'foo', :permalink => nil)
    post.permalink.should == 'foo'
  end
end

describe Post, 'parametrization' do
  it 'should use the permalink as the param' do
    permalink = String.random.downcase
    new_post(:permalink => permalink).to_param.should == permalink
  end
end
