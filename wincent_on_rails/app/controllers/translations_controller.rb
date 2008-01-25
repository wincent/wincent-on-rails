class TranslationsController < ApplicationController
  # TODO: could potentially later allow users to contribute to the translations
  # could even provide something for localizing my Cocoa applications online
  before_filter :require_admin

  # translations route is nested inside locale route so some set up is necessary
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
