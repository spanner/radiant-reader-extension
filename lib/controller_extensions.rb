module ControllerExtensions    # for inclusion into ApplicationController

  # returns a layout name for processing by radiant_layout

  def layout_for(interface = :reader)
    if defined? Site && current_site
      current_site.layout_for(interface)
    elsif default_layout = Radiant::Config["#{interface}.layout"]
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







