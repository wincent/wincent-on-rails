class TagsController < ApplicationController
  before_filter :require_admin, :only => [:edit, :update]
  before_filter :get_tag, :only => [:show, :edit, :update]

  def index
    # BUG: information leak here (should really exclude tags which apply to items we can't access)
    respond_to do |format|
      format.html do
        @tags = Tag.where('taggings_count > 0').order('name')
      end

      # for tag autocomplete widget
      format.json do
        render json: Tag.where('taggings_count > 0')
                        .order('taggings_count DESC')
                        .pluck(:name)
      end
    end
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
    respond_to do |format|
      format.html do
        if @tag.update_attributes(params[:tag])
          flash[:notice] = 'Successfully updated'
          redirect_to @tag
        else
          flash[:error] = 'Update failed'
          render action: :edit
        end
      end

      format.js do
        if @tag.update_attributes(params[:tag])
          render json: {}
        else
          render text:   "Update failed: #{@tag.flashable_error_string}",
                 status: 422
        end
      end
    end
  end

  # NOTE/BUG: can never have a tag named "search"
  def search
    unless params[:q].blank?
      notice = []
      tags = params[:q].downcase.split(' ').uniq
      if tags.length > 10
        tags = tags[0..9]
        notice << 'Excess tags stripped from search (maximum of 10 allowed)'
      end
      @tags, @taggables = Tagging.grouped_taggables_for_tag_names tags, current_user, params[:type]
      @reachable_tags = Tag.tags_reachable_from_tags @tags[:found]
      if @tags[:not_found].length > 0
        notice <<
          "Non-existent tags excluded from search results: #{@tags[:not_found].join ', '}"
      end
      flash[:notice] = notice unless notice.empty?
    end
  end

private

  def record_not_found
    super tags_path
  end

  def get_tag
    # "soft" redirect (ie. don't actually change the URL or reload the page)
    # for tags that don't match their canonical version
    name = TagMapping.mappings[params[:id]].presence || params[:id]

    @tag = Tag.find_by_name(name) || Tag.find(params[:id])
  end
end
