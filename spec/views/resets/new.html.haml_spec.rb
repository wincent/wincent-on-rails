require File.dirname(__FILE__) + '/../../spec_helper'

describe '/resets/new' do
  include ResetsHelper

  before do
    assigns[:reset] = create_reset
    render '/resets/new'
  end

  it 'should set up a heading' do
    response.should have_tag('h1', 'Reset your passphrase')
  end

  it 'should render new form' do
    # not really sure what level of detail represents the best compromise between brittle "busy-work" and robust specs
    response.should have_tag('form[action=?][method=post]', resets_url) do
      # email address text field
      with_tag('input#reset_email_address[name=?]', 'reset[email_address]')
      with_tag('input#reset_email_address[type=?]', 'text')

      # submit button
      with_tag('input#reset_submit[name=?]', 'commit')
      with_tag('input#reset_submit[type=?]', 'submit')
      with_tag('input#reset_submit[value=?]', 'Reset passphrase')
    end
  end

  it 'should advise the user that an email will be sent' do
    response.should have_text(/an email will be sent to this address/)
  end

  it 'should show a link back to the login form' do
    response.should have_tag('a[href=?]', login_url)
  end

  describe 'with an invalid record' do
    before do
      assigns[:reset] = new_reset :user => nil
    end

    it 'should highlight errors'
  end
end

# this is a separate block because we need to set up a mock before rendering
describe '/resets/new.html.haml page title' do
  it 'should set the page title' do
    assigns[:reset] = create_reset
    template.should_receive(:page_title).with('Reset your passphrase')
    render '/resets/new'
  end
end
