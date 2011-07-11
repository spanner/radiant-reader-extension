Radiant.config do |config|
  config.namespace('reader') do |reader|
    reader.define 'allow_registration?', :default => true
    reader.define 'require_confirmation?', :default => true
    reader.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => false
    reader.define 'get_profile?', :default => true
    reader.define 'public?', :default => false
    reader.define 'confine_to_groups?', :default => false
    reader.define 'share_details?', :default => false
  end
  config.namespace('email') do |email|
    email.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => true
    email.define 'name', :allow_blank => false
    email.define 'address', :allow_blank => false 
  end
end 
