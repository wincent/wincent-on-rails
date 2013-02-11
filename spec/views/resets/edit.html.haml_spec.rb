require 'spec_helper'

describe 'resets/edit' do
  before do
    @reset = Reset.make!
    render
  end

  it 'renders edit form' do
    within("form[method=post][action='#{reset_path(@reset)}']") do |form|
      form.should have_css("input#reset_email_address[name='reset[email_address]'][type='text']")
      form.should have_css("input#passphrase[name='passphrase'][type='password']")
      form.should have_css("input#passphrase_confirmation[name='passphrase_confirmation'][type='password']")
    end
  end
end
