class GitTagsController < ApplicationController
  before_filter :get_repo
  before_filter :get_tag, :only => :show

  uses_stylesheet_links

  def index
    # we'll never route people here intentionally, but they may get here by
    # creative URL editing
    redirect_to repo_path(@repo) + '#tags'
  end

  def show
    @commit = @tag.commit
  end

private

  def get_repo
    @repo = Repo.published.find_by_permalink! params[:repo_id]
  end

  def get_tag
    @tag = @repo.repo.tag params[:id]
  rescue Git::Ref::NonExistentRefError
    # BUG: shows "requested git_tag not found"
    raise ActiveRecord::RecordNotFound
  end
end # class GitTagsController
