# Switch Capybara drivers on a per-scenario basis like this:
#
#  scenario 'this is an AJAX thing', :js => true do
#    ...
#  end
#
#  scenario "this one doesn't need JavaScript" do
#    ...
#  end
RSpec.configure do |config|
  config.before :each do
    if self.running_example.instance_variable_get(:@options)[:js]
      Capybara.current_driver = :culerity
    end
  end

  config.after :each do
    if self.running_example.instance_variable_get(:@options)[:js]
      Capybara.use_default_driver
    end
  end
end
