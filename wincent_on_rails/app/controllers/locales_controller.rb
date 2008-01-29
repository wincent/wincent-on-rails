class LocalesController < ApplicationController
  before_filter     :require_admin
  before_filter     :get_locale, :except => :index
  in_place_edit_for :locale, :description

  def index
    @locales = Locale.find(:all)
  end

  def show
    render
  end

  def edit
    render
  end

private

  def get_locale
    @locale = Locale.find_by_code(params[:id]) || Locale.find(params[:id])
  end

  def record_not_found
    super locales_path
  end
end
