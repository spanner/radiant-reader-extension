module ReaderSite

  def self.included(base)
    base.class_eval %{
      belongs_to :reader_layout, :class_name => 'Layout'
      has_many :readers
    } 
    super
  end

  def layout_for(area = :reader)
    if self.respond_to?("#{area}_layout") && layout = self.send("#{area}_layout".intern)
      layout
    elsif layout = self.reader_layout
      layout
    end
  end

end
