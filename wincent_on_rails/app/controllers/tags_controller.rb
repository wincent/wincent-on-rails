class TagsController < ApplicationController
  def index
    # TODO: perhaps should restrict visibility here as well, not sure though
    @tags = Tag.find(:all, :order => 'name')
  end

  def show
    @tag      = Tag.find_by_name(params[:id]) || Tag.find(params[:id])
    @taggings = Tagging.grouped_taggings_for_tag @tag, current_user
  end

  # NOTE/BUG: can never have a tag named "search"
  def search
    if params[:q]
      # first get the tags
      tags = params[:q].downcase.split(' ')
      @tags, @taggings = Tagging.grouped_taggings_for_tag_names tags, current_user
      if @tags[:not_found].length > 0
        flash[:notice] = "Non-existent tags excluded from search results: #{@tags[:not_found].join ', '}"
      end
    else
      redirect_to tags_path
    end
  end

private

  def record_not_found
    super tags_path
  end

end
