class TagsController < ApplicationController
  before_filter :require_admin, :only => [:edit, :update]
  before_filter :get_tag, :only => [:show, :edit, :update]
  skip_before_filter :verify_authenticity_token, :only => :search

  def index
    # BUG: information leak here (should really exclude tags which apply to items we can't access)
    @tags = Tag.where('taggings_count > 0').order('name')
  end

  def show
    @taggables      = Tagging.grouped_taggables_for_tag @tag, current_user, params[:type]
    @reachable_tags = Tag.tags_reachable_from_tags @tag
  end

  # admin only
  def edit
    render
  end

  # admin only
  def update
    if @tag.update_attributes params[:tag]
      flash[:notice] = 'Successfully updated'
      redirect_to @tag
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

  # NOTE/BUG: can never have a tag named "search"
  def search
    unless params[:q].blank?
      notices = []
      tags = params[:q].downcase.split(' ').uniq
      if tags.length > 10
        tags = tags[0..9]
        notices << 'Excess tags stripped from search (maximum of 10 allowed)'
      end
      @tags, @taggables = Tagging.grouped_taggables_for_tag_names tags, current_user, params[:type]
      @reachable_tags = Tag.tags_reachable_from_tags @tags[:found]
      if @tags[:not_found].length > 0
        notices << "Non-existent tags excluded from search results: #{@tags[:not_found].join ', '}"
      end
      flash[:notice] = notices
    end
  end

private

  def record_not_found
    super tags_path
  end

  def get_tag
    @tag = Tag.find_by_name! params[:id]
  end
end
