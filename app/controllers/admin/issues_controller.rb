class Admin::IssuesController < ApplicationController
  before_filter :require_admin
  def index
    @paginator  = Paginator.new params, Issue.count(:conditions => { :awaiting_moderation => true }), admin_issues_path
    @issues     = Issue.find :all, :offset => @paginator.offset, :conditions => { :awaiting_moderation => true },
      :order => 'created_at DESC'
  end
end
