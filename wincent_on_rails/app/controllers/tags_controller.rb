class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all, :order => 'name')
  end

  def show
    @tag      = Tag.find_by_name(params[:id]) || Tag.find(params[:id])
    @taggings = Tagging.find_all_by_tag_id(@tag.id)
  end

private

  def record_not_found
    super tags_path
  end

end
