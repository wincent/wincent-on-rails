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

  it 'should reject names containing numbers' do
    new_tag(:name => 'foo100').should fail_validation_for(:name)
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
