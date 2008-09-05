require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
require 'active_record/acts/classifiable'

describe ActiveRecord::Acts::Classifiable, '"moderate_as_spam!" method', :shared => true do
  it 'should turn off the "awaiting moderation" flag' do
    lambda { @object.moderate_as_spam! }.should change(@object, :awaiting_moderation).from(true).to(false)
  end

  it 'should change the "awaiting moderation" flag in the database' do
    @object.moderate_as_spam!
    @object.class.find(@object.id).awaiting_moderation.should == @object.awaiting_moderation
  end

  it 'should turn on the "spam" flag' do
    lambda { @object.moderate_as_spam! }.should change(@object, :spam).from(false).to(true)
  end

  it 'should change the "spam" flag in the database' do
    @object.moderate_as_spam!
    @object.class.find(@object.id).spam.should == @object.spam
  end

  it 'should not alter the comment "updated at" timestamp' do
    lambda { @object.moderate_as_spam! }.should_not change(@object, :updated_at)
  end

  it 'should not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    @object.moderate_as_spam!
    @object.class.find(@object.id).updated_at.to_s.should == @object.updated_at.to_s
  end

  it 'should update the full-text search index if appropriate' do
    needle_count.should == 0
    create_needle :model_class => @object.class.to_s, :model_id => @object.id
    count = needle_count
    count.should > 0
    @object.should_receive(:update_needles) if @object.class.private_method_defined? :update_needles
    @object.moderate_as_spam!
  end

  def needle_count
    Needle.count :conditions => { :model_class => @object.class.to_s, :model_id => @object.id }
  end
end

describe ActiveRecord::Acts::Classifiable, '"moderate_as_ham!" method', :shared => true do
  it 'should turn off the "awaiting moderation" flag' do
    lambda { @object.moderate_as_ham! }.should change(@object, :awaiting_moderation).from(true).to(false)
  end

  it 'should change the "awaiting moderation" flag in the database' do
    @object.moderate_as_ham!
    @object.class.find(@object.id).awaiting_moderation.should == @object.awaiting_moderation
  end

  it 'should turn off the "spam" flag' do
    # the spam flag starts as "off" by default anyway
    @object.moderate_as_ham!
    @object.spam.should == false
  end

  it 'should change the "spam" flag in the database' do
    @object.moderate_as_ham!
    @object.class.find(@object.id).spam.should == @object.spam
  end

  it 'should not alter the comment "updated at" timestamp' do
    lambda { @object.moderate_as_ham! }.should_not change(@object, :updated_at)
  end

  it 'should not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    @object.moderate_as_ham!
    @object.class.find(@object.id).updated_at.to_s.should == @object.updated_at.to_s
  end

  it 'should update the full-text search index if appropriate' do
    count = needle_count
    count.should == 0
    @object.should_receive(:update_needles) if @object.class.private_method_defined?(:update_needles)
    @object.moderate_as_ham!
  end

  def needle_count
    Needle.count :conditions => { :model_class => @object.class.to_s, :model_id => @object.id }
  end
end
