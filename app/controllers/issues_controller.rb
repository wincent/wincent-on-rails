class IssuesController < ApplicationController
  before_filter     :find_product, :only => [:index]
  acts_as_sortable  :by => [:kind, :id, :product_id, :summary, :status, :updated_at], :default => :updated_at, :descending => true

  def index
    if admin?
      options = { :awaiting_moderation => false, :spam => false }
    elsif logged_in?
      options = ['awaiting_moderation = FALSE AND spam = FALSE AND (public = TRUE OR user_id = ?)', current_user]
    else
      options = { :awaiting_moderation => false, :spam => false, :public => true }
    end

    # possible params that can be used to limit the scope of the search
    add_kind_scope_condition options
    add_status_scope_condition options
    options[:product_id]  = @product if @product

    @paginator  = Paginator.new params, Issue.count(:conditions => options), issues_path

    # NOTE: have an N + 1 issue here (for each product we get the product info)
    # can't just :include => :product here because that will introduce an ambiguous "updated_at" column
    # thanks to acts_as_sortable (will need to update acts as sortable)
    @issues     = Issue.find :all, sort_options.merge({ :offset => @paginator.offset, :limit => @paginator.limit, :conditions => options })
  end

private
  def find_product
    @product = Product.find_by_name(params[:product]) if params[:product]
  end

  def add_kind_scope_condition options
    if params[:kind]
      key = params[:kind].gsub(' ', '_').downcase.to_sym
      options[:kind] = Issue::KIND[key] if Issue::KIND.key? key
    end
  end

  def add_status_scope_condition options
    if params[:status]
      key = params[:status].gsub(' ', '_').downcase.to_sym
      options[:status] = Issue::STATUS[key] if Issue::STATUS.key? key
    end
  end
end
