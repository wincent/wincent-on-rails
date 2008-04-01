require File.dirname(__FILE__) + '/../spec_helper'

describe ResetsHelper do
  it 'should include the ResetHelper' do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(ResetsHelper)
  end
end
