require 'spec_helper'

describe 'resets/new' do
  before do
    @reset = Reset.make
  end

  it 'sets up breadcrumbs' do
    mock(view).breadcrumbs('Reset your passphrase')
    render
  end

  it 'sets up a heading' do
    render
    rendered.should have_selector('h1', :content => 'Reset your passphrase')
  end

  it 'renders new form' do
    render
    # not really sure what level of detail represents the best compromise
    # between brittle "busy-work" and robust specs
    rendered.should have_selector('form', :action => resets_path, :method => 'post') do |form|
      # email address text field
      form.should have_selector('input#reset_email_address', :name =>'reset[email_address]', :type => 'text')

      # submit button
      form.should have_selector('input#reset_submit', :name => 'commit', :type => 'submit', :value => 'Reset passphrase')
    end
  end

  it 'advises the user that an email will be sent' do
    render
    rendered.should contain('an email will be sent to this address')
  end

  it 'shows a link back to the login form' do
    render
    rendered.should have_selector('a', :href => login_path)
  end

  context 'with an invalid record' do
    before do
      @reset = Reset.make :user => nil
    end

    it 'highlights errors'
  end
end
