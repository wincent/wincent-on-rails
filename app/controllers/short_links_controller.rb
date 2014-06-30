class ShortLinksController < ApplicationController
  before_filter :find_link

  def show
    Link.increment_counter :click_count, @link.id

    url = @link.redirection_url
    url = redirection_prefix + url if url.start_with?('/')
    redirect_to url, status: 302
  end

private

  def find_link
    @link = Link.find(ShortLink.decode(params[:id]))
  end

  def record_not_found
    redirect_to redirection_prefix
  end

  def redirection_prefix
    APP_CONFIG['protocol'] + '://' + APP_CONFIG['host']
  end
end
