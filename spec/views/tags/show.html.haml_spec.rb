require File.dirname(__FILE__) + '/../../spec_helper'

describe '/tags/show' do
  before do
    assigns[:tag] = @tag = create_tag
    assigns[:taggables] = @taggables = OpenStruct.new
  end

  def do_render
    render '/tags/show'
  end

  it 'should have an "all tags" link' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', tags_path
    end
  end

  it 'should have a "tag search" link' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', search_tags_path
    end
  end
end
