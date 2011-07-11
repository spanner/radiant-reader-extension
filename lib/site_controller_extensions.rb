module SiteControllerExtensions
  
  def self.included(base)
    base.class_eval {
      # NB. to control access without disabling the cache we have overridden Page.cache? 
      # to return false for any page that has a group association. 
      
      def find_page_with_group_check(url)
        page = find_page_without_group_check(url)
        raise ReaderError::AccessDenied if page && !page.visible_to?(current_reader)
        page
      end
        
      def show_page_with_group_check
        show_page_without_group_check
      rescue ReaderError::AccessDenied
        if current_reader
          flash[:error] = t("reader_extension.access_denied")
          redirect_to reader_permission_denied_url
        else
          flash[:explanation] = t("reader_extension.page_not_public")
          flash[:error] = t("reader_extension.please_log_in")
          store_location
          redirect_to reader_login_url
        end
      end
        
      alias_method_chain :find_page, :group_check
      alias_method_chain :show_page, :group_check
    }
  end
end



