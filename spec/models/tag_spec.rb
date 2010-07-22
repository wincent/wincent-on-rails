require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tag, 'name validation' do
  it 'requires a name to be present' do
    Tag.make(:name => nil).should fail_validation_for(:name)
  end

  it 'requires name to be unique' do
    name = Sham.random
    Tag.make!(:name => name)
    Tag.make(:name => name).should fail_validation_for(:name)
  end

  it 'compares names in a case-insensitive manner' do
    name = Sham.random
    Tag.make!(:name => name.upcase)
    Tag.make(:name => name.downcase).should fail_validation_for(:name)
  end

  it 'accepts names containing only letters' do
    Tag.make!(:name => 'foobar').should be_valid
  end

  it 'accepts names consisting of multiple words separated by a period' do
    Tag.make!(:name => 'foo.bar').should be_valid
    Tag.make!(:name => 'foo.bar.baz').should be_valid
  end

  it 'accepts names containing numbers' do
    Tag.make(:name => 'foo100').should be_valid
  end

  it 'rejects names containing spaces' do
    Tag.make(:name => 'foo bar').should fail_validation_for(:name)
    Tag.make(:name => 'foo bar baz').should fail_validation_for(:name)
  end

  it 'rejects names starting with leading periods' do
    Tag.make(:name => '.foo').should fail_validation_for(:name)
    Tag.make(:name => '..foo').should fail_validation_for(:name)
  end

  it 'rejects names ending with trailing periods' do
    Tag.make(:name => 'foo.').should fail_validation_for(:name)
    Tag.make(:name => 'foo..').should fail_validation_for(:name)
  end

  it 'rejects names containing consecutive periods' do
    Tag.make(:name => 'foo..bar').should fail_validation_for(:name)
    Tag.make(:name => 'foo...bar').should fail_validation_for(:name)
  end

  it 'rejects names containing other punctuation' do
    Tag.make(:name => 'foo,bar').should fail_validation_for(:name)
    Tag.make(:name => 'foo-bar').should fail_validation_for(:name)
  end
end

describe Tag, 'name normalization' do
  it 'normalizes names to lowercase upon creation' do
    name = Sham.random.upcase
    tag = Tag.make(:name => name)
    tag.name.should == name.downcase
  end

  it 'normalizes names when updating attributes via the accessor' do
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

  it 'returns empty array for no tags' do
    Tag.tags_reachable_from_tag_names.should == []
  end

  it 'returns empty array for more than 5 tags' do
    Tag.tags_reachable_from_tag_names('foo', 'bar', 'baz', 'bing', 'bong', 'bang').should == []
  end

  it 'returns empty array for non-existent tag (singular)' do
    Tag.tags_reachable_from_tag_names('gibberish').should == []
  end

  it 'complains if passed nil tag name' do
    lambda { Tag.tags_reachable_from_tag_names(nil) }.should raise_error
  end

  it 'returns empty array for non-existent tags (plural)' do
    Tag.tags_reachable_from_tag_names('gibberish', 'splinkel').should == []
  end

  it 'returns tag objects for "top-level" search' do
    expected = [@updates, @security, @macosx, @ssl]
    Tag.tags_reachable_from_tag_names('nginx').should =~ expected
    Tag.tags_reachable_from_tag_names('ssl').should == [@nginx]
    Tag.tags_reachable_from_tag_names('crash').should == [@security]
  end

  it 'returns tag objects for "second level" search' do
    Tag.tags_reachable_from_tag_names('nginx', 'security').should == [@updates]
  end

  it 'excludes starting tags from returned results' do
    # tested implicitly above, but test explicitly here anyway
    Tag.tags_reachable_from_tag_names('nginx').should_not include(@nginx)
  end

  it 'returns empty array when no more results' do
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

  it 'returns empty array for no tags' do
    Tag.tags_reachable_from_tags.should == []
  end

  it 'returns empty array for more than 5 tags' do
    Tag.tags_reachable_from_tags(Tag.make!, Tag.make!, Tag.make!, Tag.make!, Tag.make!, Tag.make!).should == []
  end

  it 'returns empty array for non-existent tag (singular)' do
    fake_tag    = Tag.make
    fake_tag.id = 78321
    Tag.tags_reachable_from_tags(fake_tag).should == []
  end

  it 'complains if passed nil tag' do
    lambda { Tag.tags_reachable_from_tags(nil) }.should raise_error
  end

  it 'returns empty array for non-existent tags (plural)' do
    fake1     = Tag.make
    fake1.id  = 98712
    fake2     = Tag.make
    fake2.id  = 34510
    Tag.tags_reachable_from_tags(fake1, fake2).should == []
  end

  it 'returns tag objects for "top-level" search' do
    expected = [@updates, @security, @macosx, @ssl]
    Tag.tags_reachable_from_tags(@nginx).should =~ expected
    Tag.tags_reachable_from_tags(@ssl).should == [@nginx]
    Tag.tags_reachable_from_tags(@crash).should == [@security]
  end

  it 'returns tag objects for "second level" search' do
    Tag.tags_reachable_from_tags(@nginx, @security).should == [@updates]
  end

  it 'accepts an array rather than a list of parameters' do
    # this makes things easier for callers
    Tag.tags_reachable_from_tags([@nginx, @security]).should == [@updates]
  end

  it 'excludes starting tags from returned results' do
    # tested implicitly above, but test explicitly here anyway
    Tag.tags_reachable_from_tags(@nginx).should_not include(@nginx)
  end

  it 'returns empty array when no more results' do
    Tag.tags_reachable_from_tags(@nginx, @security, @updates).should == []
  end
end

describe Tag do
  describe '#find_with_tag_names' do
    before do
      @foo = Tag.make! :name => 'foo'
      @bar = Tag.make! :name => 'bar'
      @baz = Tag.make! :name => 'baz'
    end

    it 'finds single tags' do
      Tag.find_with_tag_names('foo').should == [@foo]
    end

    it 'finds multiple tags' do
      Tag.find_with_tag_names('foo', 'bar', 'baz').should =~ [@foo, @bar, @baz]
    end

    it 'returns an empty array when no matching tags' do
      Tag.find_with_tag_names('roy').should == []
    end

    it 'ignores blank parameters' do
      Tag.find_with_tag_names('foo', nil, ' ').should == [@foo]
      Tag.find_with_tag_names(nil).should == []
      Tag.find_with_tag_names().should == []
    end
  end

  describe '#to_param' do
    it 'returns the name' do
      Tag.make!(:name => 'foo').to_param.should == 'foo'
    end

    context 'new record' do
      it 'returns nil' do
        Tag.new.to_param.should be_nil
      end
    end

    context 'dirty record' do
      it 'returns the old (in the database) name' do
        tag = Tag.make! :name => 'foo'
        tag.name = 'bar'
        tag.to_param.should == 'foo'
      end
    end
  end
end
