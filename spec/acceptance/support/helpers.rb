module HelperMethods
  def log_in_as user
    visit '/login'
    fill_in 'Email address', :with => user.emails.first.address
    fill_in 'Passphrase', :with => Sham.passphrase
    click_button 'Log in'
  end

  def log_in_as_admin
    log_in_as User.make!(:superuser => true)
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
