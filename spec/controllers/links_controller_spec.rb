require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe LinksController do
  it_should_behave_like 'ApplicationController protected methods'
  it_should_behave_like 'ApplicationController parameter filtering'
end

describe LinksController, 'show action with permalink' do
  before do
    @permalink  = 'foo'
    @link       = create_link :permalink => @permalink
  end

  # was a bug (I'd forgotten to use the "find_link" before filter)
  it 'should find the link by the permalink' do
    Link.should_receive(:find_by_permalink).and_return(@link)
    get :show, :id => @permalink, :protocol => 'https'
  end
end

describe LinksController, 'show action with raw id' do
  before do
    @link = create_link
  end

  # was a bug (I'd forgotten to use the "find_link" before filter)
  it 'should find the link by falling back to a find by id' do
    Link.should_receive(:find_by_permalink).and_return(nil) # fail on first try, but...
    Link.should_receive(:find).and_return(@link)            # succeed on fallback
    get :show, :id => @link.id, :protocol => 'https'
  end
end
