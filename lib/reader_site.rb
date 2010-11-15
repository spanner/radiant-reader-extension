module ReaderSite

  def self.included(base)
    base.class_eval do
      belongs_to :reader_layout, :class_name => 'Layout'
      has_many :readers
    end
  end

end
