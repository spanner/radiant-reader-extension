module ReaderSite

  def self.included(base)
    base.class_eval %{
      belongs_to :reader_layout, :class_name => 'Layout'
      has_many :readers
    } 
    super
  end

  # returns a layout name for the use of radiant_layout
  # (called from controller_extension if this installation is multi-sited)
  # (also from actionmailer subclasses if you use share_layouts)
  
  def layout_for(area = :reader)
    default = Radiant::Config["#{area}.layout"]
    name = if self.respond_to?("#{area}_layout") && layout = self.send("#{area}_layout".intern)
      layout.name
    elsif layout = Layout.find_by_name(default)
      layout.name
    elsif layout = self.reader_layout
      layout.name
    end
    name
  end

end
