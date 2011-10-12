module SiteControllerExtensions
  
  def self.included(base)
    base.class_eval {
      # NB. to control access without disabling the cache we have overridden Page.cache? 
      # to return false for any page that has a group association.
      
      def find_page_with_group_check(path)
        page = find_page_without_group_check(path)
        if page && page.restricted?
          raise ReaderError::LoginRequired, t("reader_extension.page_not_public") unless current_reader
          raise ReaderError::ActivationRequired, t("reader_extension.page_not_public") unless current_reader.activated?
          raise ReaderError::AccessDenied, t("reader_extension.page_permission_denied") unless page.visible_to?(current_reader)
        end
        page
      end
      alias_method_chain :find_page, :group_check
    }
  end
end



