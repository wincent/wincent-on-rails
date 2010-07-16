module HelperMethods
  def log_in_as_admin
    user = User.make! :superuser => true
    visit '/login'
    fill_in 'Email address', :with => user.emails.first.address
    fill_in 'Passphrase', :with => Sham.passphrase
    click_button 'Log in'
  end
end

RSpec.configuration.include(HelperMethods)
