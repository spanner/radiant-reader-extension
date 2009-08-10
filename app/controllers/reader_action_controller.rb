class ReaderActionController < ApplicationController
  
  no_login_required
  before_filter :require_reader, :except => [:index, :show]
  helper_method :current_site
  radiant_layout { |controller| controller.layout_for :reader }

  def current_site
    Page.current_site if defined? Site
  end
  
end
