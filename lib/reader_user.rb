module ReaderUser

  def self.included(base)
    extend ClassMethods
    base.class_eval do
      has_one :reader, :dependent => :nullify
      attr_accessor :skip_reader_update
      include InstanceMethods
      before_save :update_reader    # there is already a before_update call that hashes the password, so we need to come in before that
    end
  end

  module ClassMethods

  end
  
  module InstanceMethods
    def update_reader
      if !new_record? && self.reader && !self.skip_reader_update
        changed_columns = Reader.user_columns & self.changed
        att = self.attributes.slice(*changed_columns)
        self.reader.send :update_with, att if att.any?
      end
      true
    end
  
    def update_with(att)
      self.skip_reader_update = true
      self.confirm_password = false
      p "updating user attributes with #{att.inspect}"
      self.update_attributes(att)
      self.skip_reader_update = false
    end
  end
end
