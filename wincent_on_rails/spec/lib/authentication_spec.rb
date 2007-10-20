require File.dirname(__FILE__) + '/../spec_helper'

module Authentication
  module Model
    module ClassMethods
      class Test
        extend Authentication::Model::ClassMethods
      end
    end
  end
end

# NOTE: these specs are duplicated in user_spec.rb, where they seem much cleaner; I am not sure where they best belong
describe Authentication::Model::ClassMethods, 'generating a passphrase' do

  it 'should generate a string 8 characters in length' do
    1_000.times { Authentication::Model::ClassMethods::Test.passphrase.size.should == 8 }
  end

  it 'should not generate the same passphrase twice' do
    passphrases = []
    1_000.times { passphrases << Authentication::Model::ClassMethods::Test.passphrase }
    passphrases.size.should == passphrases.uniq.size
  end

  it 'should not generate passphrases with ambiguous characters (0, O, 1, l, I)' do
    1_000.times { Authentication::Model::ClassMethods::Test.passphrase.should_not match(/[0O1lI]/i) }
  end

  it 'should only generate passphrases with lowercase characters' do
    1_000.times do
      passphrase = Authentication::Model::ClassMethods::Test.passphrase
      passphrase.should == passphrase.downcase
    end
  end
end
