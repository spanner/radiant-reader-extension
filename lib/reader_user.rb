module ReaderUser

  def self.included(base)
    base.class_eval do
      has_one :reader
      before_update :update_reader
    end
  end
  
  def update_reader
    if self.reader
      Reader.user_columns.each { |att| self.reader.send("#{att.to_s}=", send(att)) if send("#{att.to_s}_changed?") }
      self.reader.password_confirmation = password_confirmation if password_changed?
      self.reader.save! if self.reader.changed?
    end
  end

end
