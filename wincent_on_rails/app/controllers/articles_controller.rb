class ArticlesController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]
end
