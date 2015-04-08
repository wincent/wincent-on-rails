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
    expect(rendered).to have_css('h1', text: 'Reset your passphrase')
  end

  it 'renders new form' do
    render
    within("form[action='#{resets_path}'][method='post']") do |form|
      expect(form).to have_css('input#reset_email_address[name="reset[email_address]"][type="email"]')
      expect(form).to have_css('input[name="commit"][type="submit"][value="Reset passphrase"]')
    end
  end

  it 'advises the user that an email will be sent' do
    render
    expect(rendered).to have_content('an email will be sent to this address')
  end

  it 'shows a link back to the login form' do
    render
    expect(rendered).to have_link('log in', href: login_path)
  end

  context 'with an invalid record' do
    before do
      @reset = Reset.make user: nil
    end

    it 'highlights errors'
  end
end
