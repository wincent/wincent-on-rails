class CommitsController < ApplicationController
  before_filter :get_repo
  before_filter :get_commit, :only => :show

  def index
    # we'll never route people here intentionally, but they may get here by
    # creative URL editing
    redirect_to repo_path(@repo) + '#commits'
  end

  def show
    # TODO: pagination
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

  def record_not_found
    super @repo ? repo_path(@repo) : repos_path
  end
end # class CommitsController
