require 'spec_helper'

describe IssuesController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#search' do
    def do_get
      get :search, issue: { summary: 'foo' }
    end

    # these tests are fairly weak at the moment because I don't want to start
    # mocking the internal implementation details too much (I may already have
    # gone too far); I will add fuller specs later which test only the external
    # behaviour
    it 'should check the default_access_options' do
      mock(controller).default_access_options
      do_get
    end

    it 'calls Issue.search' do
      mock.proxy(Issue).search(anything, anything)
      do_get
    end

    it "propagates the user's sort options" do
      mock(controller).sort_options { '' }
      do_get
    end

    it 'finds all applicable issues' do
      do_get
      expect(assigns[:issues]).to be_kind_of(Array)
    end
  end
end
