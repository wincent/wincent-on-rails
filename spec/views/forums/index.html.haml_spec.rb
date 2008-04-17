require File.dirname(__FILE__) + '/../../spec_helper'

describe '/forums/index' do
  include ForumsHelper

  before do
    # use Forum.find_all here because it sets up "last_active_at" attributes for us
    3.times { create_forum }
    assigns[:forums] = Forum.find_all
    render '/forums/index'
  end

  it 'should show breadcrumbs' do
    response.should have_tag('div#breadcrumbs', /Forums/) do
      with_tag 'a[href=?]', root_path
    end
  end
end
