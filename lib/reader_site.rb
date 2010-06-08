module ReaderSite

  def self.included(base)
    base.class_eval %{
      belongs_to :reader_layout, :class_name => 'Layout'
      has_many :readers
    } 
    super
  end

end
