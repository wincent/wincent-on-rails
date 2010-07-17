require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe LinksController do
  it_should_behave_like 'ApplicationController protected methods'
end

describe LinksController, 'show action with permalink' do
  before do
    @link = Link.make! :permalink => 'foo'
  end

  # was a bug (I'd forgotten to use the "find_link" before filter)
  it 'should find the link by the permalink' do
    mock(Link).find_by_permalink('foo') { @link }
    get :show, :id => 'foo'
  end
end

describe LinksController, 'show action with raw id' do
  before do
    @link = Link.make!
  end

  # was a bug (I'd forgotten to use the "find_link" before filter)
  it 'should find the link by falling back to a find by id' do
    stub(Link).find_by_permalink(@link.id) { nil }  # fail on first try, but...
    mock(Link).find(@link.id) { @link }             # succeed on fallback
    get :show, :id => @link.id
  end
end
