class TranslationsController < ApplicationController

  # translations route is nested inside locale route
  before_filter :get_locale

  # TODO: provide UI for setting up new translations
  # probably need nested resources here
  # eg. translations/locale/1
  # possibly paginate as well
  def index
    @translations = @locale.translations
  end

  def show
    @translation  = @locale.translations.find(params[:id])
    render
  end

private

  def get_locale
    @locale = Locale.find_by_code(params[:locale_id]) || Locale.find(params[:locale_id])
  end
end
