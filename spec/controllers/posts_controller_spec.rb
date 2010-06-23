require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'hpricot'

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

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  it 'should produce entry links to HTML-formatted records' do
    do_get
    doc = Hpricot.XML(response.body)
    (doc/:entry).collect do |entry|
      (entry/:link).first[:href].each do |href|
        # make sure links are /blog/foo, not /blog/foo.atom
        href.should_not =~ %r{\.html\z}
      end
    end
  end
end

describe PostsController, 'GET /blog/:permalink.atom' do
  integrate_views # so that we can test layouts as well

  before do
    @post = create_post :permalink => 'hello'
  end

  def do_get
    get :show, :id => 'hello', :format => 'atom', :protocol => 'https'
  end

  # make sure we don't get bitten by bugs like:
  # https://wincent.com/issues/1227
  it 'should produce valid atom when there are no comments' do
    pending unless can_validate_feeds?
    do_get
    response.body.should be_valid_atom
  end

  it 'should produce valid atom when there are multiple posts' do
    pending unless can_validate_feeds?
    10.times { create_comment :commentable => @post }
    do_get
    response.body.should be_valid_atom
  end
end
