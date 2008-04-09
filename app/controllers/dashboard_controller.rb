class DashboardController < ApplicationController
  before_filter :require_user

  def show
    conditions = { :user_id => current_user, :spam => false }
    @issues   = Issue.find :all, :conditions => conditions, :limit => 10, :order => 'updated_at DESC'
    @topics   = Topic.find :all, :conditions => conditions, :include => :forum, :limit => 10, :order => 'topics.updated_at DESC'
    @comments = Comment.find :all, :conditions => conditions, :limit => 10, :order => 'updated_at DESC'
  end
end
