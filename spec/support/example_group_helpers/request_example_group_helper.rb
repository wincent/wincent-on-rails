module RequestExampleGroupHelpers
  def default_url_options; {}; end
  include Rails.application.routes.url_helpers

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
