class DashboardController < ApplicationController
  before_filter :require_user

  def show
    render
  end
end
