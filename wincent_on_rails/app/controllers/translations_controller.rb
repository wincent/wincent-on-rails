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
    render
  end

private

  # translations route is nested inside locale route
  def get_locale
    if params[:locale_id] =~ /\A\d+\z/
      # raises ActiveRecord::RecordNotFound if this first find fails
      @locale = Locale.find(params[:locale_id])
    else
      @locale = Locale.find_by_code(params[:locale_id])
    end
    # raises NoMethodError if second find failed (because @locale is nil)
    #@translation  = @locale.translations.find(params[:id]) if params[:id]
  end
end
