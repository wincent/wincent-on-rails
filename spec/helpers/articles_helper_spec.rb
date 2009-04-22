require File.dirname(__FILE__) + '/../spec_helper'

describe ArticlesHelper do
end

describe ArticlesHelper, 'body_html method (removed with Rails 2.2.0)' do
  include ArticlesHelper

  # the body_html method is no longer needed as of Rail 2.2.0 due to a behaviour change
  # but we retain a specs here to catch any further behaviour changes in the future
  it 'should use the empty string as an article body on new records' do
    Article.new.body.should == ''
  end
end
