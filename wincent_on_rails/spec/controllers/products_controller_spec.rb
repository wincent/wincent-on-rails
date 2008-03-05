require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/application_spec'

describe ProductsController do
  it_should_behave_like 'ApplicationController'
end

describe ProductsController, 'index action' do
  it 'should be successful' do
    get :index
    response.should be_success
  end

  it 'should render the index template' do
    get :index
    response.should render_template('index')
  end
end
