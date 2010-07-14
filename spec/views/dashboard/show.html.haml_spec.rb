require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'dashboard/show' do
  before do
    @issues = []
    @topics = []
    @comments = []
  end

  context 'viewed as admin user' do
    before do
      user = User.make! :superuser => true
      stub(view).current_user { user }
      stub(view).admin? { true }
      render
    end

    it 'provides a link to the admin dashboard' do
      rendered.should have_selector('.links a', :href => admin_dashboard_path)
    end
  end

  context 'viewed as normal user' do
    before do
      user = User.make! :superuser => false
      stub(view).current_user { user }
      stub(view).admin? { false }
      render
    end

    it 'does not provide a link to the admin dashboard' do
      rendered.should_not have_selector('a', :href => admin_dashboard_path)
    end
  end
end
