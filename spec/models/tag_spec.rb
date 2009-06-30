require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do
  it 'should be valid' do
    create_tag.should be_valid
  end
end

describe Tag, 'name validation' do
  it 'should require a name to be present' do
    new_tag(:name => nil).should fail_validation_for(:name)
  end

  it 'should require name to be unique' do
    name = String.random
    create_tag(:name => name)
    new_tag(:name => name).should fail_validation_for(:name)
  end

  it 'should compare names in a case-insensitive manner' do
    name = String.random
    create_tag(:name => name.upcase)
    new_tag(:name => name.downcase).should fail_validation_for(:name)
  end

  it 'should accept names containing only letters' do
    create_tag(:name => 'foobar').should be_valid
  end

  it 'should accept names consisting of multiple words separated by a period' do
    create_tag(:name => 'foo.bar').should be_valid
    create_tag(:name => 'foo.bar.baz').should be_valid
  end

  it 'should accept names containing numbers' do
    new_tag(:name => 'foo100').should be_valid
  end

  it 'should reject names containing spaces' do
    new_tag(:name => 'foo bar').should fail_validation_for(:name)
    new_tag(:name => 'foo bar baz').should fail_validation_for(:name)
  end

  it 'should reject names starting with leading periods' do
    new_tag(:name => '.foo').should fail_validation_for(:name)
    new_tag(:name => '..foo').should fail_validation_for(:name)
  end

  it 'should reject names ending with trailing periods' do
    new_tag(:name => 'foo.').should fail_validation_for(:name)
    new_tag(:name => 'foo..').should fail_validation_for(:name)
  end

  it 'should reject names containing consecutive periods' do
    new_tag(:name => 'foo..bar').should fail_validation_for(:name)
    new_tag(:name => 'foo...bar').should fail_validation_for(:name)
  end

  it 'should reject names containing other punctuation' do
    new_tag(:name => 'foo,bar').should fail_validation_for(:name)
    new_tag(:name => 'foo-bar').should fail_validation_for(:name)
  end
end

describe Tag, 'name normalization' do
  it 'should normalize names to lowercase upon creation' do
    name = String.random.upcase
    tag = new_tag(:name => name)
    tag.name.should == name.downcase
  end

  it 'should normalize names when updating attributes via the accessor' do
    name = String.random
    tag = create_tag
    tag.name = name.upcase
    tag.name.should == name.downcase
  end
end

describe Tag, 'tags_reachable_from_tag_names method' do
  before do
    create_article      # no tags
    create_issue        # no tags
    create_article.tag  'nginx'
    create_article.tag  'nginx updates'
    create_article.tag  'nginx updates'
    create_article.tag  'nginx security updates'
    create_article.tag  'nginx'
    create_article.tag  'nginx security'
    create_article.tag  'nginx mac.os.x'
    create_post.tag     'nginx'
    create_post.tag     'ruby'
    create_post.tag     'nginx'
    create_post.tag     'nginx updates'
    create_post.tag     'nginx ssl'
    create_post.tag     'nginx'
    create_issue.tag    'security'
    create_issue.tag    'crash'
    create_issue.tag    'security crash'
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
    create_article      # no tags
    create_issue        # no tags
    create_article.tag  'nginx'
    create_article.tag  'nginx updates'
    create_article.tag  'nginx updates'
    create_article.tag  'nginx security updates'
    create_article.tag  'nginx'
    create_article.tag  'nginx security'
    create_article.tag  'nginx mac.os.x'
    create_post.tag     'nginx'
    create_post.tag     'ruby'
    create_post.tag     'nginx'
    create_post.tag     'nginx updates'
    create_post.tag     'nginx ssl'
    create_post.tag     'nginx'
    create_issue.tag    'security'
    create_issue.tag    'crash'
    create_issue.tag    'security crash'
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
    Tag.tags_reachable_from_tags(create_tag, create_tag, create_tag, create_tag, create_tag, create_tag).should == []
  end

  it 'should return empty array for non-existent tag (singular)' do
    fake_tag    = new_tag
    fake_tag.id = 78321
    Tag.tags_reachable_from_tags(fake_tag).should == []
  end

  it 'should complain if passed nil tag' do
    lambda { Tag.tags_reachable_from_tags(nil) }.should raise_error
  end

  it 'should return empty array for non-existent tags (plural)' do
    fake1     = new_tag
    fake1.id  = 98712
    fake2     = new_tag
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

