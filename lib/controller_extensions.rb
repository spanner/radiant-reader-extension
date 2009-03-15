module ControllerExtensions    # for inclusion into ApplicationController

  # returns a layout name for processing by radiant_layout
  # eg:
  # radiant_layout { |controller| controller.layout_for :forum }
  # will try these possibilities in order:
  #   current_site.forum_layout
  #   current_site.reader_layout
  #   Radiant::Config["forum.layout"]
  #   Radiant::Config["reader.layout"]
  #   a layout called 'Main'
  #   the first layout it can find
  

  def layout_for(area = :reader)
    if defined? Site && current_site
      current_site.layout_for(area)
    elsif default_layout = Radiant::Config["#{area}.layout"]
      default_layout
    elsif default_layout = Radiant::Config["reader.layout"]
      default_layout
    elsif main_layout = Layout.find_by_name('Main')
      main_layout
    elsif any_layout = Layout.find(:first)
      any_layout.name
    end
  end

end







