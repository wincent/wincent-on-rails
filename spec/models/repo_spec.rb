require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Repo do
  describe 'validation' do
    context 'name attribute' do
      it 'must be present' do
        Repo.new(:name => nil).should fail_validation_for(:name)
      end
    end

    context 'permalink attribute' do
      it 'must be present' do
        Repo.new(:permalink => nil).should fail_validation_for(:permalink)
      end
    end

    context 'path attribute' do
      it 'must be present' do
        Repo.new(:path => nil).should fail_validation_for(:path)
      end
    end
  end
end
