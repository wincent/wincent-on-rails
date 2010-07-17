require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ResetsController do
  it_should_behave_like 'ApplicationController protected methods'

  describe '#new' do
    it 'assigns a new reset' do
      get :new
      assigns[:reset].should be_kind_of(Reset)
      assigns[:reset].should be_new_record
    end

    it 'renders the resets/new template' do
      get :new
      response.should render_template('resets/new')
    end

    it 'succeeds' do
      get :new
      response.should be_success
    end
  end
end
