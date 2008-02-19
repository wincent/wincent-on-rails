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
    unless params[:q].blank?
      # first get the tags
      tags = params[:q].downcase.split(' ').uniq
      if tags.length > 10
        tags = tags[0..9]
        flash[:warning] = 'Excess tags stripped from search (maximum of 10 allowed)'
      end
      @tags, @taggings = Tagging.grouped_taggings_for_tag_names tags, current_user
      if @tags[:not_found].length > 0
        flash[:notice] = "Non-existent tags excluded from search results: #{@tags[:not_found].join ', '}"
      end
    end
  end

private

  def record_not_found
    super tags_path
  end

end
