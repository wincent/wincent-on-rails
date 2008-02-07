class TagsController < ApplicationController
  def index
    @tags = Tag.find(:all, :order => 'name')
  end
end
