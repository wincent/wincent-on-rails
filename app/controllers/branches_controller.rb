class BranchesController < ApplicationController
  before_filter :get_repo
  before_filter :get_branch, :only => :show

  uses_stylesheet_links

  def index
    # we'll never route people here intentionally, but they may get here by
    # creative URL editing
    redirect_to repo_path(@repo) + '#branches'
  end

  def show
    # TODO: pagination
    @commits = @branch.commits
  end

private

  def get_repo
    @repo = Repo.published.find_by_permalink! params[:repo_id]
  end

  def get_branch
    @branch = @repo.repo.branch params[:id]
  rescue Git::Ref::NonExistentRefError
    raise ActiveRecord::RecordNotFound
  end
end # class BranchesController
