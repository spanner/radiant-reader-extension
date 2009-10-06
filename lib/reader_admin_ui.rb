module ReaderAdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :reader, :message
      alias_method :readers, :reader
      alias_method :messages, :message

      def load_default_regions_with_reader
        load_default_regions_without_reader
        @reader = load_default_reader_regions
        @message = load_default_message_regions
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

      def load_default_message_regions
        returning OpenStruct.new do |message|
          message.show = Radiant::AdminUI::RegionSet.new do |show|
            show.preview.concat %w{preview_headers preview_body}
            show.delivery.concat %w{deliver_all deliver_unsent deliver_selection choose_recipients buttons}
          end
          message.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form edit_footer}
            edit.form.concat %w{edit_subject edit_body edit_filter_and_status}
            edit.form_bottom.concat %w{edit_timestamp edit_buttons}
          end
          message.index = Radiant::AdminUI::RegionSet.new do |index|
            index.thead.concat %w{subject_header recipients_header modify_header}
            index.tbody.concat %w{subject_cell recipients_cell modify_cell}
            index.bottom.concat %w{new_button}
          end
          message.remove = message.index
          message.new = message.edit
        end
      end
    end
  end
end

