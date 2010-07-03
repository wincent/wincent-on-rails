require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tag, 'name validation' do
  it 'should require a name to be present' do
    Tag.make(:name => nil).should fail_validation_for(:name)
  end

  it 'should require name to be unique' do
    name = Sham.random
    Tag.make!(:name => name)
    Tag.make(:name => name).should fail_validation_for(:name)
  end

  it 'should compare names in a case-insensitive manner' do
    name = Sham.random
    Tag.make!(:name => name.upcase)
    Tag.make(:name => name.downcase).should fail_validation_for(:name)
  end

  it 'should accept names containing only letters' do
    Tag.make!(:name => 'foobar').should be_valid
  end

  it 'should accept names consisting of multiple words separated by a period' do
    Tag.make!(:name => 'foo.bar').should be_valid
    Tag.make!(:name => 'foo.bar.baz').should be_valid
  end

  it 'should accept names containing numbers' do
    Tag.make(:name => 'foo100').should be_valid
  end

  it 'should reject names containing spaces' do
    Tag.make(:name => 'foo bar').should fail_validation_for(:name)
    Tag.make(:name => 'foo bar baz').should fail_validation_for(:name)
  end

  it 'should reject names starting with leading periods' do
    Tag.make(:name => '.foo').should fail_validation_for(:name)
    Tag.make(:name => '..foo').should fail_validation_for(:name)
  end

  it 'should reject names ending with trailing periods' do
    Tag.make(:name => 'foo.').should fail_validation_for(:name)
    Tag.make(:name => 'foo..').should fail_validation_for(:name)
  end

  it 'should reject names containing consecutive periods' do
    Tag.make(:name => 'foo..bar').should fail_validation_for(:name)
    Tag.make(:name => 'foo...bar').should fail_validation_for(:name)
  end

  it 'should reject names containing other punctuation' do
    Tag.make(:name => 'foo,bar').should fail_validation_for(:name)
    Tag.make(:name => 'foo-bar').should fail_validation_for(:name)
  end
end

describe Tag, 'name normalization' do
  it 'should normalize names to lowercase upon creation' do
    name = Sham.random.upcase
    tag = Tag.make(:name => name)
    tag.name.should == name.downcase
  end

  it 'should normalize names when updating attributes via the accessor' do
    name = Sham.random
    tag = Tag.make!
    tag.name = name.upcase
    tag.name.should == name.downcase
  end
end

describe Tag, 'tags_reachable_from_tag_names method' do
  before do
    Article.make!      # no tags
    Issue.make!        # no tags
    Article.make!.tag  'nginx'
    Article.make!.tag  'nginx updates'
    Article.make!.tag  'nginx updates'
    Article.make!.tag  'nginx security updates'
    Article.make!.tag  'nginx'
    Article.make!.tag  'nginx security'
    Article.make!.tag  'nginx mac.os.x'
    Post.make!.tag     'nginx'
    Post.make!.tag     'ruby'
    Post.make!.tag     'nginx'
    Post.make!.tag     'nginx updates'
    Post.make!.tag     'nginx ssl'
    Post.make!.tag     'nginx'
    Issue.make!.tag    'security'
    Issue.make!.tag    'crash'
    Issue.make!.tag    'security crash'
    @nginx    = Tag.find_by_name 'nginx'
    @updates  = Tag.find_by_name 'updates'
    @security = Tag.find_by_name 'security'
    @macosx   = Tag.find_by_name 'mac.os.x'
    @ruby     = Tag.find_by_name 'ruby'
    @ssl      = Tag.find_by_name 'ssl'
    @crash    = Tag.find_by_name 'crash'
  end

  it 'should return empty array for no tags' do
    Tag.tags_reachable_from_tag_names.should == []
  end

  it 'should return empty array for more than 5 tags' do
    Tag.tags_reachable_from_tag_names('foo', 'bar', 'baz', 'bing', 'bong', 'bang').should == []
  end

  it 'should return empty array for non-existent tag (singular)' do
    Tag.tags_reachable_from_tag_names('gibberish').should == []
  end

  it 'should complain if passed nil tag name' do
    lambda { Tag.tags_reachable_from_tag_names(nil) }.should raise_error
  end

  it 'should return empty array for non-existent tags (plural)' do
    Tag.tags_reachable_from_tag_names('gibberish', 'splinkel').should == []
  end

  it 'should return tag objects for "top-level" search' do
    expected = [@updates, @security, @macosx, @ssl]
    Tag.tags_reachable_from_tag_names('nginx').should =~ expected
    Tag.tags_reachable_from_tag_names('ssl').should == [@nginx]
    Tag.tags_reachable_from_tag_names('crash').should == [@security]
  end

  it 'should return tag objects for "second level" search' do
    Tag.tags_reachable_from_tag_names('nginx', 'security').should == [@updates]
  end

  it 'should exclude starting tags from returned results' do
    # tested implicitly above, but test explicitly here anyway
    Tag.tags_reachable_from_tag_names('nginx').should_not include(@nginx)
  end

  it 'should return empty array when no more results' do
    Tag.tags_reachable_from_tag_names('nginx', 'security', 'updates').should == []
  end
end

describe Tag, 'tags_reachable_from_tags method' do
  before do
    Article.make!      # no tags
    Issue.make!        # no tags
    Article.make!.tag  'nginx'
    Article.make!.tag  'nginx updates'
    Article.make!.tag  'nginx updates'
    Article.make!.tag  'nginx security updates'
    Article.make!.tag  'nginx'
    Article.make!.tag  'nginx security'
    Article.make!.tag  'nginx mac.os.x'
    Post.make!.tag     'nginx'
    Post.make!.tag     'ruby'
    Post.make!.tag     'nginx'
    Post.make!.tag     'nginx updates'
    Post.make!.tag     'nginx ssl'
    Post.make!.tag     'nginx'
    Issue.make!.tag    'security'
    Issue.make!.tag    'crash'
    Issue.make!.tag    'security crash'
    @nginx    = Tag.find_by_name 'nginx'
    @updates  = Tag.find_by_name 'updates'
    @security = Tag.find_by_name 'security'
    @macosx   = Tag.find_by_name 'mac.os.x'
    @ruby     = Tag.find_by_name 'ruby'
    @ssl      = Tag.find_by_name 'ssl'
    @crash    = Tag.find_by_name 'crash'
  end

  it 'should return empty array for no tags' do
    Tag.tags_reachable_from_tags.should == []
  end

  it 'should return empty array for more than 5 tags' do
    Tag.tags_reachable_from_tags(Tag.make!, Tag.make!, Tag.make!, Tag.make!, Tag.make!, Tag.make!).should == []
  end

  it 'should return empty array for non-existent tag (singular)' do
    fake_tag    = Tag.make
    fake_tag.id = 78321
    Tag.tags_reachable_from_tags(fake_tag).should == []
  end

  it 'should complain if passed nil tag' do
    lambda { Tag.tags_reachable_from_tags(nil) }.should raise_error
  end

  it 'should return empty array for non-existent tags (plural)' do
    fake1     = Tag.make
    fake1.id  = 98712
    fake2     = Tag.make
    fake2.id  = 34510
    Tag.tags_reachable_from_tags(fake1, fake2).should == []
  end

  it 'should return tag objects for "top-level" search' do
    expected = [@updates, @security, @macosx, @ssl]
    Tag.tags_reachable_from_tags(@nginx).should =~ expected
    Tag.tags_reachable_from_tags(@ssl).should == [@nginx]
    Tag.tags_reachable_from_tags(@crash).should == [@security]
  end

  it 'should return tag objects for "second level" search' do
    Tag.tags_reachable_from_tags(@nginx, @security).should == [@updates]
  end

  it 'should accept an array rather than a list of parameters' do
    # this makes things easier for callers
    Tag.tags_reachable_from_tags([@nginx, @security]).should == [@updates]
  end

  it 'should exclude starting tags from returned results' do
    # tested implicitly above, but test explicitly here anyway
    Tag.tags_reachable_from_tags(@nginx).should_not include(@nginx)
  end

  it 'should return empty array when no more results' do
    Tag.tags_reachable_from_tags(@nginx, @security, @updates).should == []
  end
end

