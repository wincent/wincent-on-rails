require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  it 'should include the ApplicationHelper' do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(ApplicationHelper)
  end
end

describe ApplicationHelper, 'timeinfo method' do
  before do
    @model = mock('model', :created_at => 2.days.ago, :updated_at => 3.days.ago)
  end

  it 'should get the creation date' do
    @model.should_receive(:created_at).and_return(Time.now)
    timeinfo @model
  end

  it 'should get update date' do
    @model.should_receive(:updated_at).and_return(Time.now)
    timeinfo @model
  end

  it 'should return just the creation date if update and creation date are the same (exact match)' do
    date = 2.days.ago
    @model.should_receive(:created_at).and_return(date)
    @model.should_receive(:updated_at).and_return(date)
    timeinfo(@model).should == date.distance_in_words
  end

  it 'should return just the creation date if update and creation date are the same (fuzzy match)' do
    earlier_date  = (2.days + 2.hours).ago
    later_date    = (2.days + 1.hour).ago
    @model.should_receive(:created_at).and_return(earlier_date)
    @model.should_receive(:updated_at).and_return(later_date)
    earlier_date.distance_in_words.should == later_date.distance_in_words # check our assumption about fuzzy equality
    timeinfo(@model).should == later_date.distance_in_words
  end

  it 'should return both creation and edit date if different' do
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    @model.should_receive(:created_at).and_return(earlier_date)
    @model.should_receive(:updated_at).and_return(later_date)
    earlier_date.distance_in_words.should_not == later_date.distance_in_words # check our assumption about inequality
    timeinfo(@model).should == "Created #{earlier_date.distance_in_words}, updated #{later_date.distance_in_words}"
  end

  it 'should allow you to override the "updated" string' do
    # for some model types, it might sound better to say "edited" rather than updated
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    @model.should_receive(:created_at).and_return(earlier_date)
    @model.should_receive(:updated_at).and_return(later_date)
    expected = "Created #{earlier_date.distance_in_words}, edited #{later_date.distance_in_words}"
    timeinfo(@model, :updated_string => 'edited').should == expected
  end
end

describe ApplicationHelper, 'product_options method' do
  it 'should find all products' do
    Product.should_receive(:find).with(:all).and_return([])
    product_options
  end

  it 'should return an array of name/id pairs' do
    # no need to sort as ActiveRecord/MySQL will return the rows in id order
    Product.delete_all
    product1 = create_product :name => 'foo'
    product2 = create_product :name => 'bar'
    product_options.should == [['foo', product1.id], ['bar', product2.id]]
  end
end

describe ApplicationHelper, 'underscores_to_spaces method' do
  # hashes are unordered collections, so must sort the converted arrays before comparing
  it 'should return an array of name/id pairs' do
    hash = { 'foo' => 1, 'bar' => 2 }
    underscores_to_spaces(hash).sort.should == [['foo', 1], ['bar', 2]].sort
  end

  it 'should convert underscores to spaces' do
    hash = { 'foo_bar' => 1, 'baz_bar' => 2 }
    underscores_to_spaces(hash).sort.should == [['foo bar', 1], ['baz bar', 2]].sort
  end

  it 'should convert symbol-based keys to strings' do
    hash = { :foo => 1, :bar => 2 }
    underscores_to_spaces(hash).sort.should == [['foo', 1], ['bar', 2]].sort
  end
end
