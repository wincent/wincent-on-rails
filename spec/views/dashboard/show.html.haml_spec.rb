require 'spec_helper'

describe 'dashboard/show' do
  before do
    @issues = []
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
      expect(rendered).to have_link('Admin dashboard', href: admin_dashboard_path)
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
      expect(rendered).not_to have_css("a[href='#{admin_dashboard_path}']")
    end
  end
end
