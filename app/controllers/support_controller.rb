class SupportController < ApplicationController
  acts_as_sortable  :by => [:public, :kind, :id, :product_id, :summary, :status, :updated_at],
                    :default => :updated_at,
                    :descending => true

  def index
    issues = Issue.where default_access_options # in ApplicationController
    @paginator = RestfulPaginator.new params, issues.count, issues_path
    @issues = issues.order(arel_sort_options).offset(@paginator.offset).
      limit(@paginator.limit)
  end
end
