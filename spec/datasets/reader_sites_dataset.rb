class ReaderSitesDataset < Dataset::Base
  uses :home_page
  
  def load
    create_record Site, :mysite, :name => 'My Site', :domain => 'mysite.domain.com', :base_domain => 'mysite.domain.com', :position => 1, :homepage_id => page_id(:home)
    create_record Site, :yoursite, :name => 'Your Site', :domain => '^yoursite', :base_domain => 'yoursite.test.com', :position => 2
    create_record Site, :test, :name => 'Test host', :domain => '^test\.', :base_domain => 'test.host', :position => 6
    Page.current_site = sites(:test) if defined? Site
  end
end
