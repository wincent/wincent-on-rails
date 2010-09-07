require 'spec_helper'

describe 'resets/edit' do
  before do
    @reset = Reset.make!
    render
  end

  it 'renders edit form' do
    rendered.should have_selector("form[method=post]", :action => reset_path(@reset)) do |form|
      form.should have_selector('input#reset_email_address', :name => 'reset[email_address]', :type => 'text')
      form.should have_selector('input#passphrase', :name => 'passphrase', :type => 'password')
      form.should have_selector('input#passphrase_confirmation', :name => 'passphrase_confirmation', :type => 'password')
    end
  end
end


