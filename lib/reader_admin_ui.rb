module ReaderAdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :reader, :message, :group, :reader_configuration, :account
      alias_method :readers, :reader
      alias_method :messages, :message
      alias_method :groups, :group
      alias_method :accounts, :account      #note to self: plurals are called by region_helper

      def load_reader_extension_regions
        @reader = load_default_reader_regions
        @message = load_default_message_regions
        @group = load_default_group_regions
        @reader_configuration = load_default_reader_configuration_regions
        @account = load_default_account_regions
      end

      def load_default_regions_with_reader
        load_default_regions_without_reader
        load_reader_extension_regions
      end
      alias_method_chain :load_default_regions, :reader

    protected

      def load_default_reader_regions
        OpenStruct.new.tap do |reader|
          reader.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form}
            edit.form.concat %w{edit_name edit_email edit_username edit_password reader_groups edit_description edit_notes}
            edit.form_bottom.concat %w{edit_timestamp edit_buttons}
          end
          reader.index = Radiant::AdminUI::RegionSet.new do |index|
            index.thead.concat %w{title_header description_header modify_header}
            index.tbody.concat %w{title_cell description_cell modify_cell}
            index.bottom.concat %w{buttons}
          end
          reader.remove = reader.index
          reader.new = reader.edit
        end
      end

      def load_default_reader_configuration_regions
        OpenStruct.new.tap do |reader_configuration|
          reader_configuration.show = Radiant::AdminUI::RegionSet.new do |show|
            show.settings.concat %w{administration}
            show.messages.concat %w{administration}
          end
          reader_configuration.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form}
            edit.form.concat %w{edit_registration edit_sender}
            edit.form_bottom.concat %w{edit_buttons}
          end
        end
      end

      def load_default_message_regions
        OpenStruct.new.tap do |message|
          message.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form edit_footer}
            edit.form.concat %w{edit_subject edit_body edit_group}
            edit.form_bottom.concat %w{edit_timestamp edit_buttons}
          end
          message.index = Radiant::AdminUI::RegionSet.new do |index|
            index.thead.concat %w{subject_header sent_header modify_header}
            index.tbody.concat %w{subject_cell sent_cell modify_cell}
            index.bottom.concat %w{buttons}
          end
          message.show = Radiant::AdminUI::RegionSet.new do |show|
            show.header.concat %w{title}
            show.preview.concat %w{headers body buttons}
            show.delivery.concat %w{function options}
            show.footer.concat %w{notes}
          end
          message.new = message.edit
        end
      end

      def load_default_group_regions
        OpenStruct.new.tap do |group|
          group.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form}
            edit.form.concat %w{edit_group edit_timestamp edit_buttons}
          end
          group.show = Radiant::AdminUI::RegionSet.new do |show|
            show.header.concat %w{title}
            show.main.concat %w{messages pages members}
            show.footer.concat %w{notes javascript}
          end
          group.index = Radiant::AdminUI::RegionSet.new do |index|
            index.thead.concat %w{name_header home_header members_header pages_header modify_header}
            index.tbody.concat %w{name_cell home_cell members_cell pages_cell modify_cell}
            index.bottom.concat %w{buttons}
          end
          group.remove = group.index
          group.new = group.edit
        end
      end
    end
    
    def load_default_account_regions
      OpenStruct.new.tap do |account|
        account.dashboard = Radiant::AdminUI::RegionSet.new do |dashboard|
          dashboard.main.concat %w{dashboard/welcome dashboard/groups dashboard/description}
          dashboard.sidebar.concat %w{dashboard/profile dashboard/messages dashboard/directory}
        end
        account.index = Radiant::AdminUI::RegionSet.new do |index|
          index.main.concat %w{list}
          index.sidebar.concat %w{groups/all}
        end
        account.show = Radiant::AdminUI::RegionSet.new do |show|
          show.main.concat %w{groups description}
          show.sidebar.concat %w{profile}
        end
        account.edit = Radiant::AdminUI::RegionSet.new do |edit|
          edit.main.concat %w{preamble form gravatar}
          edit.form.concat %w{edit_name edit_email edit_username edit_password}
          edit.form_bottom.concat %w{edit_buttons}
        end
        account.edit_profile = Radiant::AdminUI::RegionSet.new do |edit_profile|
          edit_profile.main.concat %w{edit_header edit_form}
          edit_profile.form.concat %w{edit_honorific edit_name edit_email edit_phone edit_mobile edit_address edit_shareability}
          edit_profile.form_bottom.concat %w{edit_buttons}
        end
        account.new = account.edit
      end
    end
    
  end
end

