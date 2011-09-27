Radiant.config do |config|
  config.namespace('reader') do |reader|
    reader.define 'allow_registration?', :default => true
    reader.define 'require_confirmation?', :default => true
    reader.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => false
    reader.define 'get_profile?', :default => true
    reader.define 'public?', :default => false
    reader.define 'directory_visibility', :select_from => %w{public private grouped none}, :allow_blank => false, :default => 'private'
    reader.define 'share_details?', :default => false
    reader.define 'profiles_path', :default => "directory"
    reader.define 'preferences_path', :default => "account"
    reader.define 'login_to', :default => "dashboard"
  end
  config.namespace('email') do |email|
    email.define 'layout', :select_from => lambda { Layout.all.map(&:name) }, :allow_blank => true
    email.define 'name', :allow_blank => false
    email.define 'address', :allow_blank => false
  end
end 
