class Admin::ForumsController < ApplicationController
  before_filter     :require_admin
  in_place_edit_for :forum, :position
  in_place_edit_for :forum, :name
  in_place_edit_for :forum, :description

  def index
    @forums = Forum.find :all
  end
end
