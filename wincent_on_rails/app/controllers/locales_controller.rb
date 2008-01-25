class LocalesController < ApplicationController
  before_filter         :require_admin
  in_place_edit_for     :locale, :description

  def index
    @locales = Locale.find(:all)
  end

  def show
    @locale = Locale.find_by_code(params[:id]) || Locale.find(params[:id])
  end
end
