module ReaderAdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :reader
      alias_method :readers, :reader

      def load_default_regions_with_reader
        @reader = load_default_reader_regions
      end

      alias_method_chain :load_default_regions, :reader

      protected

        def load_default_reader_regions
          returning OpenStruct.new do |reader|
            reader.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{edit_name edit_email edit_username edit_password edit_description edit_status edit_notes}
              edit.form_bottom.concat %w{edit_timestamp edit_buttons}
            end
            reader.index = Radiant::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{title_header description_header modify_header}
              index.tbody.concat %w{title_cell description_cell modify_cell}
              index.bottom.concat %w{new_button}
            end
            reader.remove = reader.index
            reader.new = reader.edit
          end
        end
      
    end
  end
end

