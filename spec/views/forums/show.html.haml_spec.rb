require File.dirname(__FILE__) + '/../../spec_helper'

describe '/forums/show' do
  include ForumsHelper

  before do
    @name = String.random
    assigns[:forum]   = create_forum :name => @name
    assigns[:topics]  = []
    render '/forums/show'
  end

  it 'should show breadcrumbs' do
    response.should have_tag('div#breadcrumbs', /#{@name}/) do
      with_tag 'a[href=?]', root_path
      with_tag 'a[href=?]', forums_path
    end
  end

  it 'should show the forum name as a major heading' do
    response.should have_tag('h1.major', /#{@name}/)
  end
end
