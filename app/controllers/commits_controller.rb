class CommitsController < ApplicationController
  before_filter :get_repo
  before_filter :get_commit, :only => :show

  uses_stylesheet_links

  def index
    # we'll never route peole here intentionally, but they may get here by
    # creative URL editing
    redirect_to repo_path(@repo) + '#commits'
  end

  def show
    render
  end

private

  def get_repo
    @repo = Repo.published.find_by_permalink! params[:repo_id]
  end

  def get_commit
    @commit = @repo.repo.commit params[:id]
  rescue Git::Commit::NoCommitError, Git::Commit::UnreachableCommitError
    raise ActiveRecord::RecordNotFound
  end
end # class CommitsController
