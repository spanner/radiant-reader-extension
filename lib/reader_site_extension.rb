module ReaderSiteExtension

  def self.included(base)
    base.class_eval %{
      belongs_to :reader_layout, :class_name => 'Layout'
    } 
    super
  end

  def reader_layout_or_default
    self.reader_layout_id ? self.reader_layout : Layout.find_by_name(Radiant::Config['readers.layout'])
  end

end
