class ReposController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
  before_filter :get_repo, :only => [:destroy, :edit, :show, :update]

  def index
    render
  end

  def new
    @repo = Repo.new
  end

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

private

  def record_not_found
    super repos_path
  end

  def get_repo
    @repo = Repo.find_by_permalink! params[:id]
  end
end
