require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController, 'GET /blog.atom' do
  integrate_views # so that we can test layouts as well

  def do_get
    get :index, :format => 'atom', :protocol => 'https'
  end

  # make sure we don't get bitten by bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom when there are no posts' do
    pending unless can_validate_feeds?
    Post.destroy_all
    do_get
    response.body.should be_valid_atom
  end

  it 'should produce valid atom when there are multiple posts' do
    pending unless can_validate_feeds?
    10.times { create_post }
    do_get
    response.body.should be_valid_atom
  end
end

