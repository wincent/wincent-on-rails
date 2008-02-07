require File.dirname(__FILE__) + '/../spec_helper'

describe Locale do
  it 'should be valid' do
    create_locale.should be_valid
  end
end
