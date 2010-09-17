class CommitsController < ApplicationController
  before_filter :get_repo, :only => :show
  before_filter :get_commit, :only => :show

  uses_stylesheet_links

  def show
    render
  end

private

  def get_repo
    @repo = Repo.published.find_by_permalink!(params[:repo_id])
  end

  def get_commit
    @commit = @repo.repo.commit params[:id]
  rescue Git::Commit::NoCommitError
    raise ActiveRecord::RecordNotFound
  end
end # class CommitsController
