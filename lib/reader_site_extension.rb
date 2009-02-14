module ReaderSiteExtension

  def self.included(base)
    base.class_eval %{
      belongs_to :reader_layout, :class_name => 'Layout'
    } 
    super
  end

  def reader_layout_or_default
    self.reader_layout.nil? ? Radiant::Config['readers.layout'] || 'Main' : self.reader_layout.name
  end

end
