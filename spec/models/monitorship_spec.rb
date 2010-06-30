require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Monitorship, 'validation' do
  it 'should require the user association to be set' do
    Monitorship.new.should fail_validation_for(:user)
  end

  it 'should require the monitorable association to be set' do
    Monitorship.new.should fail_validation_for(:monitorable)
  end
end

describe Monitorship, 'database constraints' do
  it 'should bail if user association is NULL' do
    lambda {
      Monitorship.make(:user => nil).save :validate => false
    }.should raise_error(ActiveRecord::StatementInvalid, /user.+cannot be null/)
  end

  it 'should bail if monitrable association is NULL' do
    lambda {
      Monitorship.make(:monitorable => nil).save :validate => false
    }.should raise_error(ActiveRecord::StatementInvalid, /monitorable.+cannot be null/)
  end
end
