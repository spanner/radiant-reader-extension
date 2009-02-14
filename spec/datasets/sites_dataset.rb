class SitesDataset < Dataset::Base
  uses :pages
  
  def load
    if defined? MultiSiteExtension
      create_record Site, :mysite, :name => 'My Site', :domain => 'mysite.domain.com', :base_domain => 'mysite.domain.com', :position => 1, :homepage_id => page_id(:home)
      create_record Site, :yoursite, :name => 'Your Site', :domain => '^yoursite', :base_domain => 'yoursite.test.com', :position => 2
    end
  end
end