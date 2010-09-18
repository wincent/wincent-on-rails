class ReposController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
  before_filter :get_repo, :only => [:destroy, :edit, :show, :update]

  def index
    # for now only show public repos; may later want to add admin-only
    # viewing of private repos, but possibly under the admin namespace
    # to allow page-caching here
    @repos = Repo.published
  end

  # Admin only.
  def new
    @repo = Repo.new
  end

  # Admin only.
  def create
    @repo = Repo.new params[:repo]
    if @repo.save
      flash[:notice] = 'Successfully created new repo'
      redirect_to @repo
    else
      flash[:error] = 'Failed to create new repo'
      render :action => 'new'
    end
  end

  def show
    render
  end

  # Admin only.
  def edit
    render
  end

  # Admin only.
  def update
    if @repo.update_attributes params[:repo]
      flash[:notice] = 'Successfully updated'
      redirect_to @repo
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

  # Admin only.
  def destroy
    @repo.destroy
    flash[:notice] = 'Successfully destroyed'
    redirect_to repos_path
  end

private

  def record_not_found
    super repos_path
  end

  def get_repo
    # TODO: let admin see private repos
    @repo = Repo.published.find_by_permalink! params[:id]
  end
end
