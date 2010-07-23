require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Admin::IssuesController do
  it_has_behavior 'ApplicationController protected methods'

  describe '#index' do
    before do
      log_in_as_admin
    end

    it 'runs the "require_admin" before_filter' do
      mock(controller).require_admin
      get :index
    end

    it 'renders the index template' do
      get :index
      response.should render_template('index')
    end

    it 'is successful' do
      get :index
      response.should be_success
    end

    # was a bug: https://wincent.com/issues/1100
    it 'paginates in groups of 20' do
      paginator = Paginator.new({}, 100, 'foo', 20)
      mock(Paginator).new(anything, anything, anything, 20) { paginator }
      mock(paginator).limit
      get :index
    end
  end
end
