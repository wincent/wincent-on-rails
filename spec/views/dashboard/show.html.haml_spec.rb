require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/dashboard/show viewed as admin user' do
  include DashboardHelper

  before do
    template.stub!(:current_user).and_return(new_user)
    template.should_receive(:admin?).and_return(true)
    assigns[:issues] = []
    assigns[:topics] = []
    assigns[:comments] = []
    render '/dashboard/show'
  end

  it 'should provide a link to the admin dashboard' do
    response.should have_tag('.links') do
      with_tag 'a[href=?]', admin_dashboard_path
    end
  end
end

describe '/dashboard/show viewed as normal user' do
  include DashboardHelper

  before do
    template.stub!(:current_user).and_return(new_user)
    template.should_receive(:admin?).and_return(false)
    assigns[:issues] = []
    assigns[:topics] = []
    assigns[:comments] = []
    render '/dashboard/show'
  end

  it 'should not provide a link to the admin dashboard' do
    response.should_not have_tag('a[href=?]', admin_dashboard_path)
  end
end
