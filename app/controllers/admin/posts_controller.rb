class Admin::PostsController < ApplicationController
  before_filter     :require_admin
  in_place_edit_for :post, :title
  in_place_edit_for :post, :permalink

  # TODO: really need a published_at field, I think
  # TODO: add "public", "accepts comments" and "comments_count" columns here
  acts_as_sortable  :by => [:title, :permalink, :created_at], :default => :created_at

  def index
    # TODO: combine sortability with pagination?
    @posts = Post.find(:all, sort_options)
  end
end
