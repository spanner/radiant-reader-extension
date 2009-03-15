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

  def layout_for(area = :reader)
    if self.respond_to?("#{area}_layout") && layout = self.send("#{area}_layout".intern)
      layout.name
    elsif layout = self.reader_layout
      layout.name
    end
  end

end
