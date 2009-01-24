require File.dirname(__FILE__) + '/../../spec_helper'

describe '/tags/index' do
  before do
    assigns[:tags] = [create_tag]
  end

  def do_render
    render '/tags/index'
  end

  it 'should have a "tag search" link' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', search_tags_url
    end
  end
end
