class Admin::TagsController < ApplicationController
  before_filter     :require_admin
  in_place_edit_for :tag, :name
  acts_as_sortable  :by => [:name, :taggings_count], :default => :name

  def index
    @tags = Tag.find :all, sort_options
  end
end
