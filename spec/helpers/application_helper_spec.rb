require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
end

describe ApplicationHelper, 'timeinfo method' do
  before do
    @model = mock('model', :created_at => 2.days.ago, :updated_at => 3.days.ago)
  end

  it 'should get the creation date' do
    @model.should_receive(:created_at).and_return(Time.now)
    helper.timeinfo @model
  end

  it 'should get update date' do
    @model.should_receive(:updated_at).and_return(Time.now)
    helper.timeinfo @model
  end

  it 'should return just the creation date if update and creation date are the same (exact match)' do
    date = 2.days.ago
    @model.should_receive(:created_at).and_return(date)
    @model.should_receive(:updated_at).and_return(date)
    helper.timeinfo(@model).should == date.distance_in_words
  end

  it 'should return just the creation date if update and creation date are the same (fuzzy match)' do
    earlier_date  = (2.days + 2.hours).ago
    later_date    = (2.days + 1.hour).ago
    @model.should_receive(:created_at).and_return(earlier_date)
    @model.should_receive(:updated_at).and_return(later_date)
    earlier_date.distance_in_words.should == later_date.distance_in_words # check our assumption about fuzzy equality
    helper.timeinfo(@model).should == later_date.distance_in_words
  end

  it 'should return both creation and edit date if different' do
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    @model.should_receive(:created_at).and_return(earlier_date)
    @model.should_receive(:updated_at).and_return(later_date)
    earlier_date.distance_in_words.should_not == later_date.distance_in_words # check our assumption about inequality
    helper.timeinfo(@model).should == "Created #{earlier_date.distance_in_words}, updated #{later_date.distance_in_words}"
  end

  it 'should allow you to override the "updated" string' do
    # for some model types, it might sound better to say "edited" rather than updated
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    @model.should_receive(:created_at).and_return(earlier_date)
    @model.should_receive(:updated_at).and_return(later_date)
    expected = "Created #{earlier_date.distance_in_words}, edited #{later_date.distance_in_words}"
    helper.timeinfo(@model, :updated_string => 'edited').should == expected
  end
end

describe ApplicationHelper, 'product_options method' do
  it 'should find all products' do
    Product.should_receive(:find).with(:all).and_return([])
    helper.product_options
  end

  it 'should return an array of name/id pairs' do
    # no need to sort as ActiveRecord/MySQL will return the rows in id order
    Product.delete_all
    product1 = create_product :name => 'foo'
    product2 = create_product :name => 'bar'
    helper.product_options.should == [['foo', product1.id], ['bar', product2.id]]
  end
end

describe ApplicationHelper, 'underscores_to_spaces method' do
  # hashes are unordered collections, so must sort the converted arrays before comparing
  it 'should return an array of name/id pairs' do
    hash = { 'foo' => 1, 'bar' => 2 }
    helper.underscores_to_spaces(hash).sort.should == [['foo', 1], ['bar', 2]].sort
  end

  it 'should convert underscores to spaces' do
    hash = { 'foo_bar' => 1, 'baz_bar' => 2 }
    helper.underscores_to_spaces(hash).sort.should == [['foo bar', 1], ['baz bar', 2]].sort
  end

  it 'should convert symbol-based keys to strings' do
    hash = { :foo => 1, :bar => 2 }
    helper.underscores_to_spaces(hash).sort.should == [['foo', 1], ['bar', 2]].sort
  end
end

describe ApplicationHelper, '"button_to_destroy_issue" method' do
  include ApplicationHelper
  before do
    @issue = create_issue
  end

  # NOTE: rather than testing an internal implementation detail like this, a better way to keep DRY might be to
  # test the button_to_destroy_model method as a "shared" behaviour, and then test the button_to_destroy_issue method
  # using "it_should_behave_like"
  it 'should call the "button_to_destroy_model" method' do
    should_receive(:button_to_destroy_model).with(@issue, issue_path(@issue))
    button_to_destroy_issue @issue
  end
end

describe ApplicationHelper, '"button_to_moderate_issue_as_spam" method' do
  include ApplicationHelper
  before do
    @issue = create_issue
  end

  it 'should call the "button_to_moderate_model_as_spam" method' do
    should_receive(:button_to_moderate_model_as_spam).with(@issue, issue_path(@issue))
    button_to_moderate_issue_as_spam @issue
  end
end

describe ApplicationHelper, '"button_to_moderate_issue_as_ham" method' do
  include ApplicationHelper
  before do
    @issue = create_issue
  end

  it 'should call the "button_to_moderate_model_as_ham" method' do
    should_receive(:button_to_moderate_model_as_ham).with(@issue, issue_path(@issue))
    button_to_moderate_issue_as_ham @issue
  end
end
