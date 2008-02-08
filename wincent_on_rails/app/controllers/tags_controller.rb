class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all, :order => 'name')
  end

  def show
    @tag = Tag.find_by_name(params[:tag_id]) || Tag.find(params[:tag_id])
  end
end
