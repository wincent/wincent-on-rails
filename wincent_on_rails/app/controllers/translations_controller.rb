class TranslationsController < ApplicationController
  # TODO: could potentially later allow users to contribute to the translations
  # could even provide something for localizing my Cocoa applications online
  before_filter     :require_admin

  # translations route is nested inside locale route so some set up is necessary
  before_filter     :get_locale
  before_filter     :get_translation, :except => :index

  in_place_edit_for :translation, :translation

  # TODO: possibly paginate here
  def index
    @translations = @locale.translations
  end

  def show
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => @translation.to_xml }
    end
  end

  def edit
    render
  end

  def update
    @translation.update_attributes!(params[:translation])
    redirect_to locale_translation_path(@translation.locale, @translation)
  end

private

  def get_locale
    @locale = Locale.find_by_code(params[:locale_id]) || Locale.find(params[:locale_id])
  end

  def get_translation
    @translation = @locale.translations.find(params[:id])
  end

  def record_not_found
    super(@locale ? locale_translations_path(@locale) : locales_path)
  end
end
