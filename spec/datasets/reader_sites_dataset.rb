class ReaderSitesDataset < Dataset::Base
  uses :pages
  
  def load
    create_record Site, :mysite, :name => 'My Site', :domain => 'mysite.domain.com', :base_domain => 'mysite.domain.com', :position => 1, :homepage_id => page_id(:home)
    create_record Site, :test, :name => 'Test Site', :domain => 'test', :base_domain => 'test.host', :position => 2, :mail_from_name => 'test sender', :mail_from_address => 'sender@spanner.org'
    create_record Site, :yoursite, :name => 'Your Site', :domain => '^yoursite', :base_domain => 'yoursite.test.com', :position => 3
    create_record Site, :default, :name => 'Default', :domain => '', :base_domain => 'spanner.org', :position => 4
    
    Page.current_site = sites(:test)
  end
 
end