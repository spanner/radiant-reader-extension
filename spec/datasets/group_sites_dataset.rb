class GroupSitesDataset < Dataset::Base
  uses :pages
  
  def load
    create_record Site, :test, :name => 'Test Site', :domain => 'test', :base_domain => 'test.host', :position => 1, :mail_from_name => 'test sender', :mail_from_address => 'sender@spanner.org', :homepage_id => page_id(:home)
    create_record Site, :elsewhere, :name => 'Another Site', :domain => '^elsewhere', :base_domain => 'elsewhere.test.com', :position => 2
    create_record Site, :default, :name => 'Default', :domain => '', :base_domain => 'spanner.org', :position => 3
    Page.current_site = sites(:test)
  end
 
end