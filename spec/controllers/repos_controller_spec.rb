require 'spec_helper'

describe ReposController do
  describe '#index' do
    it 'renders repos/index' do
      get :index
      response.should render_template('repos/index')
    end
  end
end
