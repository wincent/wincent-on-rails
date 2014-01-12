require 'spec_helper'

describe TweetsController do
  it_should_behave_like 'ApplicationController subclass'

  describe '#index' do
    it 'redirects' do
      get :index
      response.should redirect_to(APP_CONFIG['twitter_url'])
    end
  end

  describe '#show' do
    it 'redirects' do
      get :show, id: '1'
      response.should redirect_to(APP_CONFIG['twitter_url'])
    end
  end
end
