# Switch Capybara drivers on a per-scenario basis like this:
#
#  scenario 'this is an AJAX thing', :js => true do
#    ...
#  end
#
#  scenario "this one doesn't need JavaScript" do
#    ...
#  end
Rspec.configure do |config|
  config.before :each do |d|
    # TODO: find out how to access arbitrary metadata here in RSpec 2
    #Capybara.current_driver = :culerity if option[:js]
  end

  config.after :each do
    # TODO: find out how to access arbitrary metadata here in RSpec 2
    #Capybara.use_default_driver if option[:js]
  end
end
