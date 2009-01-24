require File.dirname(__FILE__) + '/../../spec_helper'

describe '/resets/edit' do
  include ResetsHelper

  before do
    assigns[:reset] = @reset = create_reset
    render '/resets/edit'
  end

  it 'should render edit form' do
    response.should have_tag("form[action=#{reset_url(@reset)}][method=post]") do
      with_tag('input#reset_email_address[name=?]', 'reset[email_address]')
      #with_tag('input#reset_passphrase[name=?]', 'reset[passphrase]') # type password
    end
  end
end


