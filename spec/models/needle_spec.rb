require File.dirname(__FILE__) + '/../spec_helper'

describe Needle do
  before(:each) do
    @needle = Needle.new
  end

  it "should be valid" do
    @needle.should be_valid
  end
end

describe Needle::NeedleQuery do
  # unfortunately this spec is tied fairly intimately to Rails' specific way of preparing queries
  # (use of backticks, for example) but it is the easiest way to test the class
  it 'should handle a complex example' do
    input = "title:foo bar http://example.com/ body:http://example.org bad: don't body:body-building :badder"
    query = Needle::NeedleQuery.new(input)
    query.prepare_clauses
    query.clauses.should == [
      "`needles`.`attribute_name` = 'title' AND `needles`.`content` = 'foo'",
      "`needles`.`content` = 'bar'",
      "`needles`.`content` = 'http://example.com/'",
      "`needles`.`attribute_name` = 'body' AND `needles`.`content` = 'http://example.org'",
      "`needles`.`content` = 'bad'",
      "`needles`.`content` = 'don'",
      "`needles`.`attribute_name` = 'body' AND `needles`.`content` = 'body'",
      "`needles`.`attribute_name` = 'body' AND `needles`.`content` = 'building'",
      "`needles`.`content` = 'badder'"
      ]
  end
end
